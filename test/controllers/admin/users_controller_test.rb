require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @super_admin = users(:super_admin)
    @user = users(:one)
  end

  test "should redirect index when unauthenticated" do
    get admin_users_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect edit when unauthenticated" do
    get edit_admin_user_url(users(:one))
    assert_redirected_to new_user_session_url
  end

  test "admin can update unions but not role" do
    sign_in_as(@admin)

    patch admin_user_url(@user), params: { user: { role: "super_admin", union_ids: [unions(:one).id, unions(:two).id] } }

    assert_redirected_to admin_users_url
    @user.reload
    assert_equal "member", @user.role
    assert_equal [unions(:one).id], @user.union_ids
  end

  test "admin cannot access create user page" do
    sign_in_as(@admin)

    get new_admin_user_url

    assert_redirected_to admin_root_url
  end

  test "super admin can create user" do
    sign_in_as(@super_admin)

    assert_difference("User.count", 1) do
      post admin_users_url, params: {
        user: {
          email: "new.user@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "admin",
          union_ids: [unions(:one).id]
        }
      }
    end

    assert_redirected_to admin_users_url
    created_user = User.find_by!(email: "new.user@example.com")
    assert_equal "admin", created_user.role
    assert_equal [unions(:one).id], created_user.union_ids
  end

  test "super admin cannot create super_admin role from user form" do
    sign_in_as(@super_admin)

    post admin_users_url, params: {
      user: {
        email: "member.only@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: "super_admin",
        union_ids: [unions(:one).id]
      }
    }

    created_user = User.find_by!(email: "member.only@example.com")
    assert_equal "member", created_user.role
  end

  test "super admin can update user role and assign multiple unions" do
    sign_in_as(@super_admin)

    patch admin_user_url(@user), params: {
      user: {
        role: "admin",
        union_ids: [unions(:one).id, unions(:two).id]
      }
    }

    assert_redirected_to admin_users_url
    @user.reload
    assert_equal "admin", @user.role
    assert_equal [unions(:one).id, unions(:two).id].sort, @user.union_ids.sort
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
