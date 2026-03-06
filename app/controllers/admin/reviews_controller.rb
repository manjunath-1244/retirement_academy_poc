class Admin::ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_course_list
  before_action :set_section
  before_action :set_review, only: [:edit, :update, :destroy]

  def index
    @reviews = @section.reviews.order(:created_at)
  end

  def new
    @review = @section.reviews.new
  end

  def create
    @review = @section.reviews.new(review_params)

    if @review.save
      redirect_to admin_course_list_course_list_section_reviews_path(@course_list, @section), notice: "Review question added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @review.update(review_params)
      redirect_to admin_course_list_course_list_section_reviews_path(@course_list, @section), notice: "Review question updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to admin_course_list_course_list_section_reviews_path(@course_list, @section), notice: "Review question deleted."
  end

  private

  def set_course_list
    @course_list = admin_accessible_course_scope.find(params[:course_list_id])
  end

  def set_section
    @section = @course_list.course_list_sections.find(params[:course_list_section_id])
  end

  def set_review
    @review = @section.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:question, :answer)
  end
end
