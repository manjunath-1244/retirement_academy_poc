require "test_helper"

class Admin::CourseListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @super_admin = users(:super_admin)
    @course_for_admin = CourseList.create!(title: "Union One Course", description: "Visible to union one")
    @course_for_admin.visible_to_unions.create!(union: unions(:one))

    @other_course = CourseList.create!(title: "Union Two Course", description: "Visible to union two")
    @other_course.visible_to_unions.create!(union: unions(:two))
  end

  test "should redirect index when unauthenticated" do
    get admin_course_lists_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect show when unauthenticated" do
    get admin_course_list_url(@course_for_admin)
    assert_redirected_to new_user_session_url
  end

  test "admin sees only courses from their unions" do
    sign_in_as(@admin)

    get admin_course_lists_url

    assert_response :success
    assert_includes response.body, @course_for_admin.title
    assert_not_includes response.body, @other_course.title
  end

  test "admin cannot access course outside their unions" do
    sign_in_as(@admin)

    get admin_course_list_url(@other_course)

    assert_response :not_found
  end

  test "admin cannot assign course to other union" do
    sign_in_as(@admin)

    assert_difference("CourseList.count", 1) do
      post admin_course_lists_url, params: {
        course_list: {
          title: "Admin Created Course",
          description: "Scoped create",
          union_ids: [unions(:one).id, unions(:two).id]
        }
      }
    end

    created = CourseList.find_by!(title: "Admin Created Course")
    assert_equal [unions(:one).id], created.union_ids
  end

  test "super admin sees all courses in admin panel" do
    sign_in_as(@super_admin)

    get admin_course_lists_url

    assert_response :success
    assert_includes response.body, @course_for_admin.title
    assert_includes response.body, @other_course.title
  end

  test "admin cannot reorder courses" do
    sign_in_as(@admin)

    patch reorder_admin_course_lists_url, params: { course_ids: [@other_course.id, @course_for_admin.id] }, as: :json

    assert_redirected_to admin_root_url
  end

  test "super admin can reorder courses by drag and drop endpoint" do
    sign_in_as(@super_admin)

    patch reorder_admin_course_lists_url, params: { course_ids: [@other_course.id, @course_for_admin.id] }, as: :json

    assert_response :success
    assert_equal 1, @other_course.reload.position
    assert_equal 2, @course_for_admin.reload.position
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
