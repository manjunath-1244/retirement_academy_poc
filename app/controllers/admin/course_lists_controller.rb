class Admin::CourseListsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :require_super_admin, only: [:reorder]
  before_action :set_course_list, only: [:show, :edit, :update, :destroy]

  def index
    @course_lists = admin_accessible_course_scope.includes(:unions).order(:position, :title)
  end

  def reorder
    course_ids = Array(params[:course_ids]).map(&:to_i)
    return head :unprocessable_entity if course_ids.empty?

    CourseList.transaction do
      course_ids.each_with_index do |id, index|
        CourseList.where(id: id).update_all(position: index + 1)
      end
    end

    head :ok
  end

  def show; end

  def new
    @course_list = CourseList.new
    @available_unions = admin_assignable_unions
  end

  def create
    @course_list = CourseList.new(course_list_params)
    @available_unions = admin_assignable_unions

    if @course_list.save
      redirect_to admin_course_list_path(@course_list), notice: "Course created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_unions = admin_assignable_unions
  end

  def update
    if @course_list.update(course_list_params)
      redirect_to admin_course_list_path(@course_list), notice: "Course updated successfully."
    else
      @available_unions = admin_assignable_unions
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course_list.destroy
    redirect_to admin_course_lists_path, notice: "Course deleted successfully."
  end

  private

  def set_course_list
    @course_list = admin_accessible_course_scope.find(params[:id])
  end

  def course_list_params
    permitted = params.require(:course_list).permit(
      :title,
      :description,
      union_ids: [],
      course_list_sections_attributes: [
        :id,
        :title,
        :position,
        :_destroy,
        videos_attributes: [:id, :title, :description, :file, :_destroy],
        images_attributes: [:id, :title, :description, :file, :_destroy],
        text_contents_attributes: [:id, :body, :_destroy]
      ]
    )

    requested_union_ids = normalize_union_ids(params.dig(:course_list, :union_ids))
    allowed_union_ids = if current_user.super_admin?
                          requested_union_ids
                        else
                          requested_union_ids & current_user.union_ids_for_access
                        end

    permitted[:union_ids] = allowed_union_ids
    permitted
  end

  def normalize_union_ids(raw_ids)
    Array(raw_ids).reject(&:blank?).map(&:to_i)
  end
end
