class Admin::CourseListSectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_course_list
  before_action :set_section, only: [:show, :edit, :update, :destroy]

  def index
    @sections = @course_list.course_list_sections.order(:position, :id)
  end

  def show; end

  def new
    @section = @course_list.course_list_sections.new
    apply_default_section_values(@section)

    if @section.save
      redirect_to admin_course_list_course_list_section_path(@course_list, @section, open_picker: 1), notice: "Section created. Choose content to add."
    else
      redirect_to admin_course_list_course_list_sections_path(@course_list), alert: "Unable to create section."
    end
  end

  def create
    @section = @course_list.course_list_sections.new(section_params)
    apply_default_section_values(@section)

    if @section.save
      redirect_to admin_course_list_course_list_section_path(@course_list, @section), notice: "Section created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @section.update(section_params)
      redirect_to admin_course_list_course_list_section_path(@course_list, @section), notice: "Section updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @section.destroy
    redirect_to admin_course_list_course_list_sections_path(@course_list), notice: "Section deleted successfully."
  end

  private

  def set_course_list
    @course_list = admin_accessible_course_scope.find(params[:course_list_id])
  end

  def set_section
    @section = @course_list.course_list_sections.find(params[:id])
  end

  def section_params
    params.fetch(:course_list_section, {}).permit(:title, :position)
  end

  def apply_default_section_values(section)
    next_position = @course_list.course_list_sections.maximum(:position).to_i + 1
    section.position = next_position if section.position.blank?
    section.title = "Section #{section.position}" if section.title.blank?
  end
end
