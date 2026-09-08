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

    assert_equal @referer, ref["session_referer_url"], "should have saved referer url"
    assert_equal "http://#{host}/users", ref["session_first_url"], "should have saved first url"
  end

  test "should not update session in second requests" do
    get '/users', headers: {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}
    assert_response :success

    user = User.first
    get "/users/#{user.id}", headers: {"HTTP_REFERER" => "second_url"}

    ref = session["referer_tracking"]
    assert_equal @referer, ref["session_referer_url"], "should not touch referer_url"
    assert_equal "http://#{host}/users", ref["session_first_url"], "should not touch first_url"

    assert_equal "CUSTOM_VAL", ref["show_action"], "should have added custom value that was set in show action source file"

  end

  # Regression: the session hash round-trips through the cookie, and since Rails 7.0
  # serializes it as JSON there are no symbols on the way back. add_info used to look
  # its key up as a symbol, so the "already set" guard never matched and every request
  # overwrote the value it was supposed to keep.
  test "add_info should keep the value from the first request" do
    user = User.first
    get "/users/#{user.id}", params: {custom_val: "from_first_request"}
    assert_equal "from_first_request", session["referer_tracking"]["show_action"]

    get "/users/#{user.id}", params: {custom_val: "from_second_request"}
    assert_equal "from_first_request", session["referer_tracking"]["show_action"],
                 "add_info must not overwrite a value set on an earlier request"
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
    assert_equal "http://www.example.com/users?gclib=some_keyword&pass=xxxx&more=things", ref_session["session_first_url"]

    ref_track = RefererTracking::Tracking.order(:created_at).last
    assert !ref_track.blank?, "did not create ref tracking"

    assert_equal @referer, ref_track.session_referer_url
    assert_equal ref_session["session_first_url"], ref_track.session_first_url

    assert_equal @referer, ref_track.cookie_referer_url
    assert_equal ref_session["session_first_url"], ref_track.cookie_first_url
    assert 10.minutes.ago < ref_track.cookie_time && ref_track.cookie_time < Time.now

    assert_equal @user_agent, ref_track.user_agent

    assert_equal 'testing_request_add', ref_track.request_added
    assert_equal 'testing_session_add', ref_track.session_added
    assert_equal "testing_session_add_without_db_column", ref_track.infos_session["session_added_hash"]
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

  test "custom referer_tracking save work with too long user agent" do
    RefererTracking.save_cookies = true

    too_long_user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_2_6 like Mac OS X) AppleWebKit/604.5.6 (KHTML, like Gecko) Mobile/15D100 [FBAN/MessengerForiOS; ... #{(0...400).map { (65+rand(26)).chr }.join}"
    post '/users/create_with_custom_saving', params: {:user => {:name => 'test name'}},
         headers: {"HTTP_USER_AGENT" => (@user_agent = too_long_user_agent)}
    assert_equal 1, RefererTracking::Tracking.count, "should create one item"

    assert too_long_user_agent.size > 400
    rt = RefererTracking::Tracking.last
    assert_equal too_long_user_agent.first(100), rt.user_agent.first(100)
    assert rt.user_agent.size < 255, "should handle db limits" # testing manually because sqlite does not enforce limits same way as mysql
  end



  test "custom referer_tracking save should not save if item itself is not saved" do
    RefererTracking.save_cookies = true

    post '/users/build_without_saving', params: {:user => {:name => 'test name'}}, headers: {"HTTP_USER_AGENT" => (@user_agent = "som user agent")}
    assert_equal 0, RefererTracking::Tracking.count, "should create one item"
  end


  # Rack hands header values over tagged ASCII-8BIT, valid multibyte ones included, while it
  # unescapes cookies into UTF-8 without checking the result. Both shapes have to survive, so
  # the encoding is forced here: a literal would be tagged UTF-8 either way.
  BINARY_INVALID_REFERER = "https://example.com/h\xC3\xA4?q=\xFF".force_encoding(Encoding::BINARY)
  BINARY_VALID_REFERER = "https://example.com/hä".force_encoding(Encoding::BINARY)
  SCRUBBED_REFERER = "https://example.com/hä?q="

  test "invalid bytes in the referer are scrubbed before the session is written" do
    get '/users', headers: {"HTTP_REFERER" => BINARY_INVALID_REFERER}
    assert_response :success

    url = session["referer_tracking"]["session_referer_url"]
    assert_equal Encoding::UTF_8, url.encoding
    assert_equal SCRUBBED_REFERER, url, "should drop the invalid byte and keep the rest"
  end

  # A plain "hä" referer arrives tagged ASCII-8BIT too and used to lose its tracking row just
  # as surely as an invalid byte did. It is also the guard against sanitizing with
  # encode(invalid: :replace, undef: :replace) instead, which would store "h??" here.
  test "a valid multibyte referer arriving as binary is kept intact" do
    get '/users', headers: {"HTTP_REFERER" => BINARY_VALID_REFERER}
    post '/users', params: {:user => {:name => 'test name'}}, headers: {"HTTP_REFERER" => BINARY_VALID_REFERER}

    assert_equal "https://example.com/hä", session["referer_tracking"]["session_referer_url"]

    ref_track = RefererTracking::Tracking.last
    assert ref_track, "should have created the tracking row"
    assert_equal "https://example.com/hä", ref_track.reload.current_request_referer_url
  end

  # Every literal fragment of the message is ASCII, so interpolating a binary url does not
  # raise — the line just becomes ASCII-8BIT and Logger writes nothing. Only a log handle in
  # text mode shows that: Logger.new(path) opens one, like a handle reopened after rotation,
  # while the binmode handle Rails opens at boot takes binary happily.
  test "the first request is logged even when the referer has invalid bytes" do
    file = Tempfile.new(["referer_tracking_test", ".log"])
    ApplicationController.any_instance.stubs(:logger).returns(Logger.new(file.path))

    get '/users', headers: {"HTTP_REFERER" => BINARY_INVALID_REFERER}
    assert_response :success

    assert_match "REFERER_TRACKING_FIRST", File.read(file.path)
  ensure
    file&.close!
  end

  test "ref_track cookie is valid utf8 when the referer has invalid bytes" do
    get '/users', headers: {"HTTP_REFERER" => BINARY_INVALID_REFERER}
    assert_response :success

    assert_equal SCRUBBED_REFERER, cookies['ref_track'].split("|||").last
  end

  test "tracking row is saved with valid utf8 when the request has invalid bytes" do
    get '/users', headers: {"HTTP_REFERER" => BINARY_INVALID_REFERER}
    post '/users', params: {:user => {:name => 'test name'}},
         headers: {"HTTP_USER_AGENT" => "agent\xC3\xA4\xFF".force_encoding(Encoding::BINARY),
                   "HTTP_REFERER" => BINARY_INVALID_REFERER}

    ref_track = RefererTracking::Tracking.last
    assert ref_track, "should have created the tracking row"

    ref_track.reload
    assert_equal SCRUBBED_REFERER, ref_track.current_request_referer_url
    assert_equal "agentä", ref_track.user_agent
  end

  # Rack unescapes an incoming cookie into UTF-8 without checking the result, so a client can
  # hand us bytes that blank? and split refuse to look at and Psych refuses to dump. Sanitizing
  # the headers does not reach any of that, and the row has to survive it.
  test "invalid bytes in the incoming cookies do not lose the tracking row" do
    RefererTracking.save_cookies = true

    get '/users', headers: {"HTTP_REFERER" => "www.some-source-forward.com"}
    # Rack::Test escapes what it writes into the jar, so the invalid bytes have to go into the
    # cookie header by hand, alongside the session cookie the first request set.
    session_cookies = cookies.for(URI.parse("http://#{host}/users")).split("; ").grep_v(/\Aref_track=/)
    post '/users', params: {:user => {:name => 'test name'}},
         headers: {"HTTP_COOKIE" => (session_cookies + ["ref_track=v01|||123|||first%FF|||ref%FF", "junk=%FFbad"]).join("; ")}

    ref_track = RefererTracking::Tracking.last
    assert ref_track, "should have created the tracking row"
    assert_equal "ref", ref_track.cookie_referer_url, "should keep the cookie url with the bad byte dropped"
    assert_match "error:", ref_track.cookies_yaml, "should store the fallback text for an undumpable jar"
  end

  # Tracking is never worth failing a page over.
  test "error in the first request tracking should not result error in response" do
    ApplicationController.any_instance.stubs(:request_is_from_a_known_bot?).raises(RuntimeError, "boom")

    get '/users', headers: {"HTTP_REFERER" => "www.some-source-forward.com"}

    assert_response :success
    assert_nil session["referer_tracking"]
  end

  # A half-built hash must not reach the session: session[:referer_tracking] would stop being
  # nil, and this visitor would never be tracked again for the rest of the session.
  test "a failure while building the session leaves nothing behind and the next request retries" do
    logger = stub_everything('logger')
    logger.stubs(:info).raises(RuntimeError, "boom").then.returns(nil)
    ApplicationController.any_instance.stubs(:logger).returns(logger)

    get '/users', headers: {"HTTP_REFERER" => "www.first-request.com"}
    assert_response :success
    assert_nil session["referer_tracking"], "should not leave a half built hash in the session"

    get '/users', headers: {"HTTP_REFERER" => (referer = "www.second-request.com")}
    assert_equal referer, session["referer_tracking"]["session_referer_url"],
                 "should still track the session once the request succeeds"
  end

end
