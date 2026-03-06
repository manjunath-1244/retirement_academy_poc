require "test_helper"

class Admin::UnionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @super_admin = users(:super_admin)
    @union = unions(:one)
  end

  test "should redirect index when unauthenticated" do
    get admin_unions_url
    assert_redirected_to new_user_session_url
  end

  test "admin cannot open unions management" do
    sign_in_as(@admin)

    get admin_unions_url

    assert_redirected_to admin_root_url
  end

  test "super admin can create union and assign users" do
    sign_in_as(@super_admin)

    assert_difference("Union.count", 1) do
      post admin_unions_url, params: {
        union: {
          name: "West Union",
          subdomain: "west",
          contact_email: "west@example.com",
          user_ids: [users(:one).id, users(:admin).id, users(:super_admin).id]
        }
      }
    end

    created = Union.find_by!(name: "West Union")
    assert_includes created.user_ids, users(:one).id
    assert_includes created.user_ids, users(:admin).id
    assert_not_includes created.user_ids, users(:super_admin).id
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
