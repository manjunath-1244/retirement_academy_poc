require "test_helper"

class Admin::CourseProgressesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @super_admin = users(:super_admin)

    @course = CourseList.create!(title: "Trackable Course", description: "Track")
    @course.visible_to_unions.create!(union: unions(:one))
    @course.course_list_sections.create!(title: "S1", position: 1)
  end

  test "should redirect index when unauthenticated" do
    get admin_course_progresses_url
    assert_redirected_to new_user_session_url
  end

  test "admin can view progress page" do
    sign_in_as(@admin)

    get admin_course_progresses_url

    assert_response :success
    assert_includes response.body, "Course Progress"
  end

  test "super admin can view progress page" do
    sign_in_as(@super_admin)

    get admin_course_progresses_url

    assert_response :success
    assert_includes response.body, "Course Progress"
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
