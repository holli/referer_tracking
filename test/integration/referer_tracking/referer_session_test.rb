require File.dirname(__FILE__) + '/../../test_helper'
#require 'test_helper'

class RefererSessionTest < ActionDispatch::IntegrationTest
  fixtures :all

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
    get 'users', {}, {"HTTP_REFERER" => (@referer = "www.some-source-forward.com")}

    post 'users', {:user => {:name => 'test name'}}, {"HTTP_USER_AGENT" => (@user_agent = "som user agent")}

    ref_session = session["referer_tracking"]
    ref_track = RefererTracking::RefererTracking.order(:created_at).last

    assert !ref_track.blank?, "did not create ref tracking"
    assert_equal @referer, ref_track.referer_url
    assert_equal ref_session[:first_url], ref_track.first_url
    assert_equal @user_agent, ref_track.user_agent

    user = User.where(:name => 'test name').first

    assert_equal user.id, ref_track.trackable.id, "models didn't match from ref_track.trackable"
    
    assert_equal user.referer_tracking.id, ref_track.id, "models didn't match from user.referer_tracking"
  end

end

