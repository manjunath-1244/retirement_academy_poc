require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "shows landing page with sign in and sign up" do
    get root_url

    assert_response :success
    assert_includes response.body, "Sign In"
    assert_includes response.body, "Sign Up"
  end
end
