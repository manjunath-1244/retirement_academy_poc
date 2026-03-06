require "test_helper"

class Admin::CourseListSectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @course = CourseList.create!(title: "Sample Course", description: "Sample")
    @course.visible_to_unions.create!(union: unions(:one))
    @section = @course.course_list_sections.create!(title: "Section 1", position: 1)

    @other_course = CourseList.create!(title: "Other Course", description: "Other")
    @other_course.visible_to_unions.create!(union: unions(:two))
    @other_section = @other_course.course_list_sections.create!(title: "Section X", position: 1)
  end

  test "should redirect index when unauthenticated" do
    get admin_course_list_course_list_sections_url(@course)
    assert_redirected_to new_user_session_url
  end

  test "should redirect show when unauthenticated" do
    get admin_course_list_course_list_section_url(@course, @section)
    assert_redirected_to new_user_session_url
  end

  test "admin can access sections for own-union course" do
    sign_in_as(@admin)

    get admin_course_list_course_list_sections_url(@course)

    assert_response :success
    assert_includes response.body, @section.title
  end

  test "admin cannot access sections for other-union course" do
    sign_in_as(@admin)

    get admin_course_list_course_list_sections_url(@other_course)

    assert_response :not_found
  end

  test "new section creates section and opens content picker" do
    sign_in_as(@admin)

    assert_difference("@course.course_list_sections.count", 1) do
      get new_admin_course_list_course_list_section_url(@course)
    end

    created = @course.course_list_sections.order(:id).last
    assert_redirected_to admin_course_list_course_list_section_url(@course, created, open_picker: 1)
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
