class CourseListSectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_section

  def show
    @progress = current_user.progresses.find_by(course_list_section: @section)
    @previous_section = previous_section
    @next_section = next_section
    @ordered_sections = @course.course_list_sections.order(:position, :id).to_a
    @section_index = @ordered_sections.index { |section| section.id == @section.id }.to_i + 1
    @section_total = @ordered_sections.size
    @section_items = build_section_items
    @step = normalized_step(@section_items.size)
    @current_item = @section_items[@step - 1]
    @previous_item_step = @step > 1 ? (@step - 1) : nil
    @next_item_step = @step < @section_items.size ? (@step + 1) : nil
  end

  def complete
    progress = current_user.progresses.find_or_initialize_by(course_list_section: @section)
    progress.completed = true
    progress.save!

    maybe_mark_course_complete!

    redirect_to course_list_course_list_section_path(@course, @section), notice: "Section marked as complete. Continue to the next section."
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

  def set_section
    @section = @course.course_list_sections.find(params[:id])
  end

  def next_section
    ordered = @course.course_list_sections.order(:position, :id).to_a
    index = ordered.index { |section| section.id == @section.id }
    return if index.nil?

    ordered[index + 1]
  end

  def previous_section
    ordered = @course.course_list_sections.order(:position, :id).to_a
    index = ordered.index { |section| section.id == @section.id }
    return if index.nil? || index.zero?

    ordered[index - 1]
  end

  def maybe_mark_course_complete!
    total_sections = @course.course_list_sections.count
    return if total_sections.zero?

    completed_sections = current_user.progresses
                                     .joins(:course_list_section)
                                     .where(completed: true, course_list_sections: { course_list_id: @course.id })
                                     .count

    return unless completed_sections == total_sections

    completion = current_user.course_completions.find_or_initialize_by(course_list: @course)
    completion.completed_at ||= Time.current
    completion.save!
  end

  def build_section_items
    items = []

    @section.videos.order(:created_at, :id).each do |video|
      items << { type: :video, title: video.title, record: video }
    end

    @section.images.order(:created_at, :id).each do |image|
      items << { type: :image, title: image.title, record: image }
    end

    @section.text_contents.order(:created_at, :id).each_with_index do |text, index|
      items << { type: :text, title: "Reading #{index + 1}", body: text.body, record: text }
    end

    @section.reviews.order(:created_at, :id).each_with_index do |review, index|
      items << {
        type: :review,
        title: "Review #{index + 1}",
        question: review.question,
        answer: review.answer,
        record: review
      }
    end

    items
  end

  def normalized_step(total_items)
    return 1 if total_items.zero?

    requested = params[:step].to_i
    requested = 1 if requested <= 0
    [requested, total_items].min
  end
end
