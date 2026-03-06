class Admin::ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_course_list
  before_action :set_section
  before_action :set_image, only: [:edit, :update, :destroy]

  def index
    @images = @section.images.order(:created_at)
  end

  def new
    @image = @section.images.new
  end

  def create
    @image = @section.images.new(image_params)

    if @image.save
      redirect_to admin_course_list_course_list_section_images_path(@course_list, @section), notice: "Image added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @image.update(image_params)
      redirect_to admin_course_list_course_list_section_images_path(@course_list, @section), notice: "Image updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @image.destroy
    redirect_to admin_course_list_course_list_section_images_path(@course_list, @section), notice: "Image deleted."
  end

  private

  def set_course_list
    @course_list = admin_accessible_course_scope.find(params[:course_list_id])
  end

  def set_section
    @section = @course_list.course_list_sections.find(params[:course_list_section_id])
  end

  def set_image
    @image = @section.images.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:title, :description, :file)
  end
end
