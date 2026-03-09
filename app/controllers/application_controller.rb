class ApplicationController < ActionController::Base
  include Pundit::Authorization

  def after_sign_in_path_for(_resource)
    course_lists_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  private

  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: "You are not authorized to access this page."
  end

  def require_super_admin
    return if current_user&.super_admin?

    redirect_to admin_root_path, alert: "Only super admins can perform that action."
  end

  def admin_accessible_course_scope
    return CourseList.all if current_user&.super_admin?

    CourseList.joins(:visible_to_unions)
              .where(visible_to_unions: { union_id: current_user.union_ids_for_access })
              .distinct
  end

  def admin_assignable_unions
    return Union.order(:name) if current_user&.super_admin?

    Union.where(id: current_user.union_ids_for_access).order(:name)
  end
end
