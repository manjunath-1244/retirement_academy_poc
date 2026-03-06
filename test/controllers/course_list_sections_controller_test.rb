require "test_helper"

class CourseListSectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = CourseList.create!(title: "Retirement Basics", description: "Core module")
    @course.visible_to_unions.create!(union: unions(:one))
    @section_one = @course.course_list_sections.create!(title: "Introduction", position: 1)
    @section_two = @course.course_list_sections.create!(title: "Investing", position: 2)
    @user = users(:one)
  end

  test "should redirect show when unauthenticated" do
    get course_list_course_list_section_url(@course, @section_one)
    assert_redirected_to new_user_session_url
  end

  test "user can open second section without completing first" do
    sign_in_as(@user)

    get course_list_course_list_section_url(@course, @section_two)

    assert_response :success
  end

  test "user can still open second section after completing first" do
    sign_in_as(@user)
    post complete_course_list_course_list_section_url(@course, @section_one)

    get course_list_course_list_section_url(@course, @section_two)

    assert_response :success
  end

  test "super admin can open section without union assignment" do
    sign_in_as(users(:super_admin))

    get course_list_course_list_section_url(@course, @section_one)

    assert_response :success
  end

  test "admin can open section for course outside admin unions from courses page" do
    admin = users(:admin)
    admin_course = CourseList.create!(title: "Admin Open Any", description: "Any")
    admin_course.visible_to_unions.create!(union: unions(:two))
    section = admin_course.course_list_sections.create!(title: "Open", position: 1)
    sign_in_as(admin)

    get course_list_course_list_section_url(admin_course, section)

    assert_response :success
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
