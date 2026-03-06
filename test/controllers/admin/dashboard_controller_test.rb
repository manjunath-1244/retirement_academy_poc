require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect index when unauthenticated" do
    get admin_root_url
    assert_redirected_to new_user_session_url
  end
end
