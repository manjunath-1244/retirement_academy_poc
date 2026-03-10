require "test_helper"

class CourseListQuizzesControllerTest < ActionDispatch::IntegrationTest
  test "finishing final quiz auto-completes course and sends email when all sections are done" do
    user = users(:one)
    sign_in_as(user)

    course = CourseList.create!(title: "Quiz Completion Course", description: "Flow check")
    course.visible_to_unions.create!(union: unions(:one))
    section = course.course_list_sections.create!(title: "Section 1", position: 1)
    Progress.create!(user: user, course_list_section: section, completed: true)

    course.course_quiz_questions.create!(
      question: "Q1",
      option_one: "A",
      option_two: "B",
      option_three: "C",
      option_four: "D",
      correct_option: 1,
      answer_explanation: "A is correct.",
      position: 1
    )

    ActionMailer::Base.deliveries.clear

    post course_list_submit_quiz_url(course), params: { q: 0, selected_option: 1 }
    assert_response :success

    completion = CourseCompletion.find_by(user: user, course_list: course)
    assert_not_nil completion
    assert_not_nil completion.quiz_completed_at
    assert_not_nil completion.completed_at
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "finishing final quiz does not send email when sections are incomplete" do
    user = users(:one)
    sign_in_as(user)

    course = CourseList.create!(title: "Quiz Without Sections Completion", description: "Flow check")
    course.visible_to_unions.create!(union: unions(:one))
    course.course_list_sections.create!(title: "Section 1", position: 1)

    course.course_quiz_questions.create!(
      question: "Q1",
      option_one: "A",
      option_two: "B",
      option_three: "C",
      option_four: "D",
      correct_option: 1,
      answer_explanation: "A is correct.",
      position: 1
    )

    ActionMailer::Base.deliveries.clear

    post course_list_submit_quiz_url(course), params: { q: 0, selected_option: 1 }
    assert_response :success

    completion = CourseCompletion.find_by(user: user, course_list: course)
    assert_not_nil completion
    assert_not_nil completion.quiz_completed_at
    assert_nil completion.completed_at
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  private

  def sign_in_as(user, password: "password123")
    post user_session_url, params: { user: { email: user.email, password: password } }
  end
end
