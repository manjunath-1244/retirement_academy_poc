class CourseListQuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_questions
  # before_action :ensure_sections_completed!

  def show
    prepare_question_state
    return if performed?

    @selected_option = params[:selected_option].to_i
    @show_feedback = @selected_option.positive?
    @result = build_result(@question, @selected_option) if @show_feedback
    @quiz_finished = @show_feedback && @next_question_index.blank?
  end

  def submit
    prepare_question_state
    return if performed?

    selected_option = params[:selected_option].to_i
    if selected_option.zero?
      @show_feedback = false
      @quiz_finished = false
      flash.now[:alert] = "Please select an option."
      render :show, status: :unprocessable_entity
      return
    end

    @selected_option = selected_option
    @show_feedback = true
    @result = build_result(@question, @selected_option)
    @quiz_finished = @next_question_index.blank?

    mark_quiz_complete! if @quiz_finished
    render :show, status: :ok
  end

  private

  def set_course
    if current_user.admin?
      @course = CourseList.find(params[:course_list_id])
      return
    end

    ids = current_user.union_ids_for_access
    @course = CourseList.joins(:visible_to_unions)
                      .where(visible_to_unions: { union_id: ids })
                      .distinct
                      .find(params[:course_list_id])
  end

  def set_questions
    @questions = @course.course_quiz_questions.order(:position, :id)
    return if @questions.any?

    redirect_to course_list_path(@course), alert: "No quiz is configured for this course."
  end

  def prepare_question_state
    @question_index = normalized_question_index
    @question = @questions[@question_index]
    @next_question_index = next_question_index
    return if @question.present?

    redirect_to course_list_quiz_path(@course), alert: "Question not found."
  end

  def ensure_sections_completed!
    total_sections = @course.course_list_sections.count
    return if total_sections.zero?

    completed_sections = current_user.progresses
                                     .joins(:course_list_section)
                                     .where(completed: true, course_list_sections: { course_list_id: @course.id })
                                     .count
    return if completed_sections == total_sections

    redirect_to course_list_path(@course), alert: "Complete all sections to unlock the final quiz."
  end

  def mark_quiz_complete!
    completion = current_user.course_completions.find_or_initialize_by(course_list: @course)
    completion.quiz_completed_at ||= Time.current
    newly_completed = completion.completed_at.blank? && all_sections_completed_for_course?
    completion.completed_at ||= Time.current if newly_completed
    completion.save!

    return unless newly_completed

    CourseCompletionMailer.with(user: current_user, course: @course)
                          .completed_course_email
                          .deliver_now
  rescue StandardError => e
    Rails.logger.error("Course completion email failed for user=#{current_user.id}, course=#{@course.id}: #{e.class} - #{e.message}")
  end

  def all_sections_completed_for_course?
    total_sections = @course.course_list_sections.count
    return false if total_sections.zero?

    completed_sections = current_user.progresses
                                     .joins(:course_list_section)
                                     .where(completed: true, course_list_sections: { course_list_id: @course.id })
                                     .count
    completed_sections == total_sections
  end

  def normalized_question_index
    requested = params[:q].to_i
    requested = 0 if requested.negative?
    max_index = @questions.size - 1
    [requested, max_index].min
  end

  def next_question_index
    next_index = @question_index + 1
    next_index < @questions.size ? next_index : nil
  end

  def build_result(question, selected_option)
    {
      selected_option: selected_option,
      correct: selected_option == question.correct_option,
      correct_option: question.correct_option,
      correct_text: question.options[question.correct_option],
      explanation: question.answer_explanation
    }
  end
end
