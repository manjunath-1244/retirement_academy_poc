require "test_helper"

class CourseListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = CourseList.create!(title: "Retirement Basics", description: "Core module")
    @course.visible_to_unions.create!(union: unions(:one))
    @course.visible_to_unions.create!(union: unions(:two))
  end

  test "should redirect index when unauthenticated" do
    get course_lists_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect show when unauthenticated" do
    get course_list_url(@course)
    assert_redirected_to new_user_session_url
  end

  test "user can view course assigned to one of their unions" do
    user = users(:one)
    sign_in_as(user)

    get course_lists_url

    assert_response :success
    assert_includes response.body, @course.title
  end

  test "super admin can view all courses without union assignment" do
    user = users(:super_admin)
    sign_in_as(user)

    get course_lists_url

    assert_response :success
    assert_includes response.body, @course.title
  end

  test "admin can view all courses on learner courses page" do
    user = users(:admin)
    other_course = CourseList.create!(title: "All Admin Can See", description: "Any union")
    other_course.visible_to_unions.create!(union: unions(:two))
    sign_in_as(user)

    get course_lists_url

    assert_response :success
    assert_includes response.body, @course.title
    assert_includes response.body, other_course.title
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
