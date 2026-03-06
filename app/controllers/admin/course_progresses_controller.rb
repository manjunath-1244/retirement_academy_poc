class Admin::CourseProgressesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @available_unions = admin_assignable_unions
    @selected_union = selected_union
    @available_courses = available_courses_for(@selected_union)
    @selected_course = selected_course
    @users = users_for_selected_union
    @total_sections = @selected_course&.course_list_sections&.count.to_i
    @progress_by_user = progress_by_user
    @completion_by_user = completion_by_user
  end

  private

  def selected_union
    return if @available_unions.empty?

    requested_id = params[:union_id].presence
    @available_unions.find_by(id: requested_id) || @available_unions.first
  end

  def available_courses_for(union)
    return CourseList.none unless union

    union.course_lists.order(:title)
  end

  def selected_course
    return if @available_courses.empty?

    requested_id = params[:course_list_id].presence
    @available_courses.find_by(id: requested_id) || @available_courses.first
  end

  def users_for_selected_union
    return User.none unless @selected_union

    @selected_union.users.where(role: "member").order(:email)
  end

  def progress_by_user
    return {} unless @selected_course && @users.any?

    Progress.joins(:course_list_section)
            .where(user_id: @users.select(:id), completed: true, course_list_sections: { course_list_id: @selected_course.id })
            .group(:user_id)
            .count
  end

  def completion_by_user
    return {} unless @selected_course && @users.any?

    CourseCompletion.where(user_id: @users.select(:id), course_list_id: @selected_course.id).index_by(&:user_id)
  end
end
