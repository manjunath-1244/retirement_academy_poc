class Admin::TextContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_course_list
  before_action :set_section
  before_action :set_text_content, only: [:edit, :update, :destroy]

  def index
    @text_contents = @section.text_contents.order(:created_at)
  end

  def new
    @text_content = @section.text_contents.new
  end

  def create
    @text_content = @section.text_contents.new(text_content_params)

    if @text_content.save
      redirect_to admin_course_list_course_list_section_text_contents_path(@course_list, @section), notice: "Text content added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @text_content.update(text_content_params)
      redirect_to admin_course_list_course_list_section_text_contents_path(@course_list, @section), notice: "Text content updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @text_content.destroy
    redirect_to admin_course_list_course_list_section_text_contents_path(@course_list, @section), notice: "Text content deleted."
  end

  private

  def set_course_list
    @course_list = admin_accessible_course_scope.find(params[:course_list_id])
  end

  def set_section
    @section = @course_list.course_list_sections.find(params[:course_list_section_id])
  end

  def set_text_content
    @text_content = @section.text_contents.find(params[:id])
  end

  def text_content_params
    params.require(:text_content).permit(:body)
  end
end
