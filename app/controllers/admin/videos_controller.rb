class Admin::VideosController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_course_list
  before_action :set_section
  before_action :set_video, only: [:edit, :update, :destroy]

  def index
    @videos = @section.videos.order(:created_at)
  end

  def new
    @video = @section.videos.new
  end

  def create
    @video = @section.videos.new(video_params)

    if @video.save
      redirect_to admin_course_list_course_list_section_videos_path(@course_list, @section), notice: "Video added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @video.update(video_params)
      redirect_to admin_course_list_course_list_section_videos_path(@course_list, @section), notice: "Video updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @video.destroy
    redirect_to admin_course_list_course_list_section_videos_path(@course_list, @section), notice: "Video deleted."
  end

  private

  def set_course_list
    @course_list = admin_accessible_course_scope.find(params[:course_list_id])
  end

  def set_section
    @section = @course_list.course_list_sections.find(params[:course_list_section_id])
  end

  def set_video
    @video = @section.videos.find(params[:id])
  end

  def video_params
    params.require(:video).permit(:title, :description, :file)
  end
end
