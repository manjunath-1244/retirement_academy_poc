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

  test "completing a course sends completion email on first completion only" do
    user = users(:one)
    sign_in_as(user)

    course = CourseList.create!(title: "Email Course", description: "For mail testing")
    course.visible_to_unions.create!(union: unions(:one))
    section = course.course_list_sections.create!(title: "Section 1", position: 1)
    course.course_quiz_questions.create!(
      question: "Q1",
      option_one: "A",
      option_two: "B",
      option_three: "C",
      option_four: "D",
      correct_option: 1,
      answer_explanation: "Because A is correct.",
      position: 1
    )
    Progress.create!(user: user, course_list_section: section, completed: true)
    CourseCompletion.create!(user: user, course_list: course, quiz_completed_at: Time.current)

    ActionMailer::Base.deliveries.clear

    post complete_course_list_url(course)
    assert_redirected_to course_list_url(course)
    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.last
    assert_equal [user.email], email.to
    assert_equal "You have successfully completed the course", email.subject
    assert_includes email.body.encoded, "Email Course"
    assert_includes email.body.encoded, "North Union"

    post complete_course_list_url(course)
    assert_redirected_to course_list_url(course)
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
