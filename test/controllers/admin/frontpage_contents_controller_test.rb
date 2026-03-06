require "test_helper"

class Admin::FrontpageContentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @super_admin = users(:super_admin)
    @admin = users(:admin)
  end

  test "admin cannot edit front page content" do
    sign_in_as(@admin)

    get edit_admin_frontpage_content_url

    assert_redirected_to admin_root_url
  end

  test "super admin can edit front page content" do
    sign_in_as(@super_admin)

    get edit_admin_frontpage_content_url

    assert_response :success
  end

  test "super admin can update front page content" do
    sign_in_as(@super_admin)

    patch admin_frontpage_content_url, params: {
      frontpage_content: {
        hero_title: "New Hero",
        hero_subtitle: "Updated subtitle",
        how_it_works: "Step 1\nStep 2",
        header_text: "New Header",
        footer_text: "New Footer"
      }
    }

    assert_redirected_to edit_admin_frontpage_content_url
    content = FrontpageContent.current
    assert_equal "New Hero", content.hero_title
    assert_equal "New Header", content.header_text
    assert_equal "New Footer", content.footer_text
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
