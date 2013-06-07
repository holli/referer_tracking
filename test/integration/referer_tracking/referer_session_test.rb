require File.dirname(__FILE__) + '/../../test_helper'
#require 'test_helper'

class RefererSessionTest < ActionDispatch::IntegrationTest
  fixtures :all

  teardown do
    RefererTracking.save_cookies = false
  end

  test "should save referer to session" do
    get 'users', {}, {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}
    assert_response :success

    ref = session["referer_tracking"]
    assert !ref.blank?, "should have referer_tracking in session"

    assert_equal @referer, ref[:referer_url], "should have saved referer url"
    assert_equal "http://#{host}/users", ref[:first_url], "should have saved first url"
  end

  test "should not update session in second requests" do
    get 'users', {}, {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}
    assert_response :success

    user = User.first
    get "users/#{user.id}", {}, {"HTTP_REFERER" => "second_url"}

    ref = session["referer_tracking"]
    assert_equal @referer, ref[:referer_url], "should not touch referer_url"
    assert_equal "http://#{host}/users", ref[:first_url], "should not touch first_url"

    assert_equal "CUSTOM_VAL", ref[:show_action], "should have added custom value that was set in show action source file"

  end

  test "should be able to save models and safe referer_tracking at the same" do
    RefererTracking.save_cookies = true

    get 'users', {}, {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}

    @original_count = RefererTracking::RefererTracking.count

    post 'users', {:user => {:name => 'test name'}},
         {"HTTP_USER_AGENT" => (@user_agent = "som user agent"),
          "HTTP_REFERER" => (@current_request_referer = "localhost.inv/request_from_this_page")}

    assert_equal @original_count + 1, RefererTracking::RefererTracking.count, "did not create referer tracking"

    ref_session = session["referer_tracking"]
    ref_track = RefererTracking::RefererTracking.order(:created_at).last

    assert !ref_track.blank?, "did not create ref tracking"
    assert_equal @referer, ref_track.referer_url
    assert_equal ref_session[:first_url], ref_track.first_url
    assert_equal @user_agent, ref_track.user_agent
    assert_equal 'testing_request_add', ref_track.request_added
    assert_equal 'testing_session_add', ref_track.session_added
    assert_equal @current_request_referer, ref_track.current_request_referer_url
    assert_equal "http://www.example.com/users", ref_track.current_request_url
    assert !ref_track.session_id.blank?
    assert !YAML::load(ref_track.cookies_yaml)["_dummy_session"].blank?, "should have saved the cookies in yaml"

    user = User.where(:name => 'test name').first

    assert_equal user.id, ref_track.trackable.id, "models didn't match from ref_track.trackable"
    
    assert_equal user.referer_tracking.id, ref_track.id, "models didn't match from user.referer_tracking"

    put "users/#{user.id}", {:user => {:name => 'test name'}}, {"HTTP_USER_AGENT" => (@user_agent = "som user agent")}
    assert_equal @original_count + 1, RefererTracking::RefererTracking.count, "should not create RefererTracking on normal save"

  end


  test "error in sweeper should not result error in response" do
    get 'users', {}, {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}

    RefererTracking::RefererTracking.any_instance.stubs(:save).raises(Exception)

    post 'users', {:user => {:name => 'test name'}}, {"HTTP_USER_AGENT" => (@user_agent = "som user agent")}

    assert_response :redirect
  end



end

