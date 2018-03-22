require "./test/test_helper"

class RefererSessionTest < ActionDispatch::IntegrationTest
  fixtures :all

  teardown do
    RefererTracking.save_cookies = false
  end

  test "should save referer to session" do
    get '/users', headers: {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}
    assert_response :success

    ref = session["referer_tracking"]
    assert !ref.blank?, "should have referer_tracking in session"

    assert_equal @referer, ref[:session_referer_url], "should have saved referer url"
    assert_equal "http://#{host}/users", ref[:session_first_url], "should have saved first url"
  end

  test "should not update session in second requests" do
    get '/users', headers: {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}
    assert_response :success

    user = User.first
    get "/users/#{user.id}", headers: {"HTTP_REFERER" => "second_url"}

    ref = session["referer_tracking"]
    assert_equal @referer, ref[:session_referer_url], "should not touch referer_url"
    assert_equal "http://#{host}/users", ref[:session_first_url], "should not touch first_url"

    assert_equal "CUSTOM_VAL", ref[:show_action], "should have added custom value that was set in show action source file"

  end

  test "should be able to save models and safe referer_tracking at the same" do
    RefererTracking.save_cookies = true

    get '/users', params: {'gclib' => 'some_keyword', 'password' => 'secret', 'more' => 'things'}, headers: {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}

    assert !cookies['ref_track'].blank?, "should set tracking cookie"
    cookie_arr = cookies['ref_track'].split("|||")
    assert_equal 4, cookie_arr.length

    @original_count = RefererTracking::Tracking.count

    post '/users', params: {:user => {:name => (@name_test = "test name #{rand(9999999)}")}},
         headers: {"HTTP_USER_AGENT" => (@user_agent = "som user agent"),
                   "HTTP_REFERER" => (@current_request_referer = "localhost.inv/request_from_this_page")}

    assert_equal @original_count + 1, RefererTracking::Tracking.count, "did not create referer tracking"

    ref_session = session["referer_tracking"]
    assert_equal "http://www.example.com/users?gclib=some_keyword&pass=xxxx&more=things", ref_session[:session_first_url]

    ref_track = RefererTracking::Tracking.order(:created_at).last
    assert !ref_track.blank?, "did not create ref tracking"

    assert_equal @referer, ref_track.session_referer_url
    assert_equal ref_session[:session_first_url], ref_track.session_first_url

    assert_equal @referer, ref_track.cookie_referer_url
    assert_equal ref_session[:session_first_url], ref_track.cookie_first_url
    assert 10.minutes.ago < ref_track.cookie_time && ref_track.cookie_time < Time.now

    assert_equal @user_agent, ref_track.user_agent

    assert_equal 'testing_request_add', ref_track.request_added
    assert_equal 'testing_session_add', ref_track.session_added
    assert_equal "testing_session_add_without_db_column", ref_track.infos_session[:session_added_hash]
    assert_equal "testing_request_add_without_db_column", ref_track.infos_request[:request_added_hash]

    assert_equal @current_request_referer, ref_track.current_request_referer_url
    assert_equal "http://www.example.com/users", ref_track.current_request_url

    assert !ref_track.session_id.blank?
    assert !YAML::load(ref_track.cookies_yaml)["_dummy_session"].blank?, "should have saved the cookies in yaml"


    user = User.where(:name => @name_test).first
    assert user, "Problem in test controller, did not create user right way"
    assert_equal user, ref_track.trackable, "should be connected to created user"
    assert_equal user.id, ref_track.trackable.id, "models didn't match from ref_track.trackable"
    assert_equal user.tracking.id, ref_track.id, "models didn't match from user.referer_tracking"

    put "/users/#{user.id}", params: {:user => {:name => 'test name'}}, headers: {"HTTP_USER_AGENT" => (@user_agent = "som user agent")}
    assert_equal @original_count + 1, RefererTracking::Tracking.count, "should not create RefererTracking on normal save"

  end


  test "error in tracking save should not result error in response" do
    get '/users', headers: {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}

    RefererTracking::Tracking.any_instance.stubs(:save).raises(Exception)

    post '/users', params: {:user => {:name => 'test name'}}, headers: {"HTTP_USER_AGENT" => (@user_agent = "som user agent")}

    assert_response :redirect
  end

  test "be ok when url size limit is between encoded chars" do
    RefererTracking.set_referer_cookies_ref_url_max_length = 50
    referer_url = "http://test.xd/?url=http%3A%2F%2Ftest.inv%2Ftest%2Ftest"
    parseable_url = "http://test.xd/?url=http%3A%2F%2Ftest.inv%2Ftest%2" # first 50 chars, ending %2
    get '/users', headers: {"HTTP_REFERER" => referer_url}
    assert_response :success

    post '/users'
    assert_not_nil RefererTracking::Tracking.first, "should have created tracking"
    resulted_url = RefererTracking::Tracking.first.cookie_referer_url

    assert_equal parseable_url, resulted_url, "should have a parseable referer url"
  end

  test "should stop trying and return the original if url appears unparseable" do
    RefererTracking.set_referer_cookies_ref_url_max_length = 50
    original_url = "http\im_actually€Not-Aparseable&URL%"
    get '/users', headers: {"HTTP_REFERER" => original_url}
    assert_response :success

    post '/users'
    assert_equal 1, RefererTracking::Tracking.count, "should create one item"
    resulted_url = RefererTracking::Tracking.first.cookie_referer_url

    assert_equal original_url, resulted_url, "should return the original url when unparseable"
  end

  test "custom referer_tracking save work and still should save only one item per request" do
    RefererTracking.save_cookies = true

    post '/users/create_with_custom_saving', params: {:user => {:name => 'test name'}}, headers: {"HTTP_USER_AGENT" => (@user_agent = "som user agent")}
    assert_equal 1, RefererTracking::Tracking.count, "should create one item"
  end

  test "custom referer_tracking save should not save if item itself is not saved" do
    RefererTracking.save_cookies = true

    post '/users/build_without_saving', params: {:user => {:name => 'test name'}}, headers: {"HTTP_USER_AGENT" => (@user_agent = "som user agent")}
    assert_equal 0, RefererTracking::Tracking.count, "should create one item"
  end

end

