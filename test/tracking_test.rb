require "./test/test_helper"

class TrackingTest < ActiveSupport::TestCase
  test "module test" do
    assert_kind_of Module, RefererTracking
  end

  test "first_url_combined should return cookie url if given" do
    rt = RefererTracking::Tracking.new
    rt.session_first_url = 'session_url'
    assert_equal 'session_url', rt.first_url_combined
    rt.cookie_first_url = 'cookie_url'
    assert_equal 'cookie_url', rt.first_url_combined
  end

  test "add_log_line should work ok" do
    rt = RefererTracking::Tracking.create

    rt.add_log_line 'first_line'

    rt.add_log_line "second\nline"

    assert (log = RefererTracking::Tracking.last.log)
    assert_equal 2, log.to_s.lines.count
    assert_match /#{Date.today.to_s(:db)}.*: first_line$/, log.lines.first
    assert_match /#{Date.today.to_s(:db)}.*: second line/, log.lines.last
  end

  test "status_without_save" do
    rt_created = RefererTracking::Tracking.create
    rt_created.status = 'active'
    assert !rt_created.changed?
    rt_created.status_without_save = 'new_status'
    assert rt_created.changed?
  end

  test "status change" do
    rt_created = RefererTracking::Tracking.create
    rt_created.status = 'active'

    rt = RefererTracking::Tracking.last
    assert_equal 'active', rt.status
    assert_equal 1, rt.log.lines.count
    assert_match /#{Date.today.to_s(:db)}.*: status active$/, rt.log

    rt.status=('active')
    assert_equal 1, rt.log.lines.count, "should not alter anything if status stays the same"
  end

  test "get_log_lines" do
    rt_created = RefererTracking::Tracking.create
    rt_created.status = 'active'
    rt_created.add_log_line 'first_line common'
    rt_created.add_log_line 'second_line common'
    rt_created.add_log_line 'third thing'

    rt = RefererTracking::Tracking.last

    match_arr = rt.get_log_lines(/second/)
    assert_equal 1, match_arr.size
    result_line = match_arr.first
    assert result_line.first > 10.seconds.ago && result_line.first < Time.now
    assert result_line.last

    match_arr = rt.get_log_lines(/common/)
    assert_equal 2, match_arr.size
    assert_equal 'first_line common', match_arr.first.last
    assert_equal 'second_line common', match_arr.last.last
  end
end
