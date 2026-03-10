class CourseListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: [:show, :complete]

  def index
    @frontpage = FrontpageContent.current
    @course_lists = visible_course_scope
                    .includes(course_list_sections: [{ videos: { file_attachment: :blob } }])
                    .order(:position, :title)
    @featured_course = @course_lists.first
    @overview_video_attachment = @frontpage.overview_video if @frontpage.overview_video.attached?
    @featured_video = featured_video_for(@featured_course)
  end

  def show
    @sections = @course.course_list_sections.order(:position, :id)
    @completed_section_ids = completed_section_ids(@course)
    @course_completion = current_user.course_completions.find_by(course_list: @course)
    @quiz_available = @course.course_quiz_questions.any?
    @all_sections_completed = @sections.any? && @completed_section_ids.size == @sections.size
    @quiz_completed = @course_completion&.quiz_completed_at.present?
    @course_completed = @course_completion&.completed_at.present?
    @first_section = @sections.first

    total = @sections.count
    completed = @completed_section_ids.size

    @progress_percent = if total.zero?
                          0
                        else
                          (completed.to_f / total * 100).round
                        end
  end

  def complete
    sections = @course.course_list_sections.order(:position, :id)
    completed_ids = completed_section_ids(@course)
    all_sections_completed = sections.any? && completed_ids.size == sections.size
    quiz_available = @course.course_quiz_questions.any?
    completion = current_user.course_completions.find_or_initialize_by(course_list: @course)

    unless all_sections_completed
      redirect_to course_list_path(@course), alert: "Please complete all sections before completing the course."
      return
    end

    if quiz_available && completion.quiz_completed_at.blank?
      redirect_to course_list_quiz_path(@course), alert: "Please complete the quiz before completing the course."
      return
    end

    newly_completed = completion.completed_at.blank?
    completion.completed_at ||= Time.current
    completion.save!

    if newly_completed && all_sections_completed && completion.quiz_completed_at.present?
      begin
        CourseCompletionMailer.with(user: current_user, course: @course)
                              .completed_course_email
                              .deliver_now
      rescue StandardError => e
        Rails.logger.error("Course completion email failed for user=#{current_user.id}, course=#{@course.id}: #{e.class} - #{e.message}")
      end
    end

    redirect_to course_list_path(@course), notice: "Course completed successfully."
  end

  private

  def set_course
    @course = visible_course_scope.includes(:course_list_sections, :course_quiz_questions).find(params[:id])
  end

  def visible_course_scope
    return CourseList.all if current_user.admin?

    ids = current_user.union_ids_for_access
    return CourseList.none if ids.empty?

    CourseList.joins(:visible_to_unions)
              .where(visible_to_unions: { union_id: ids })
              .distinct
  end

  def completed_section_ids(course)
    current_user.progresses
                .joins(:course_list_section)
                .where(completed: true, course_list_sections: { course_list_id: course.id })
                .pluck(:course_list_section_id)
  end

  def featured_video_for(course)
    return unless course

    sections = course.course_list_sections.sort_by { |section| [section.position || 0, section.id] }
    sections.each do |section|
      video = section.videos.min_by { |record| [record.created_at, record.id] }
      return video if video
    end

    nil
  end
end
