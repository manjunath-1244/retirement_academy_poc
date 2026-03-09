class CourseListsController < ApplicationController
  before_action :authenticate_user!

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
    @course = visible_course_scope.includes(:course_list_sections).find(params[:id])
    @sections = @course.course_list_sections.order(:position, :id)
    @completed_section_ids = completed_section_ids(@course)

    total = @sections.count
    completed = @completed_section_ids.size

    @progress_percent = if total.zero?
                          0
                        else
                          (completed.to_f / total * 100).round
                        end
  end

  private

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
