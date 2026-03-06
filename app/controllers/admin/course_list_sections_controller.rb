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
    seed_content_blocks(@section)
  end

  def create
    @section = @course_list.course_list_sections.new(section_params)

    if @section.save
      redirect_to admin_course_list_course_list_section_path(@course_list, @section), notice: "Section created successfully."
    else
      seed_content_blocks(@section)
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @section.update(section_params)
      redirect_to admin_course_list_course_list_section_path(@course_list, @section), notice: "Section updated successfully."
    else
      seed_content_blocks(@section)
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
    params.require(:course_list_section).permit(
      :title,
      :position,
      videos_attributes: [:id, :title, :description, :file, :_destroy],
      images_attributes: [:id, :title, :description, :file, :_destroy]
    )
  end

  def seed_content_blocks(section)
    section.videos.build if section.videos.empty?
    section.images.build if section.images.empty?
  end
end
