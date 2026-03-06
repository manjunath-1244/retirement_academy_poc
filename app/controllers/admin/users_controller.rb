class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :require_super_admin, only: [:new, :create, :destroy]
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.includes(:unions).order(:email)
  end

  def new
    @user = User.new(role: "member")
    @available_unions = available_unions
  end

  def create
    @user = User.new(super_admin_user_params)
    @available_unions = available_unions

    if @user.save
      sync_legacy_union(@user)
      redirect_to admin_users_path, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @selected_union_ids = selected_union_ids(@user)
    @available_unions = available_unions
  end

  def update
    params_to_update = current_user.super_admin? ? super_admin_user_params : admin_user_params

    if @user.update(params_to_update)
      sync_legacy_union(@user)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      @selected_union_ids = selected_union_ids(@user)
      @available_unions = available_unions
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted successfully."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def admin_user_params
    permitted_union_ids = normalize_union_ids(params.dig(:user, :union_ids))
    { union_ids: permitted_union_ids & current_user.union_ids_for_access }
  end

  def super_admin_user_params
    permitted = params.require(:user).permit(:email, :password, :password_confirmation, :role, union_ids: []).to_h

    if permitted.key?("role")
      role = permitted["role"].to_s
      permitted["role"] = User::ASSIGNABLE_ROLES.include?(role) ? role : "member"
    end

    if permitted.key?("union_ids")
      permitted["union_ids"] = normalize_union_ids(permitted["union_ids"])
    end

    permitted
  end

  def selected_union_ids(user)
    user.unions.any? ? user.union_ids : Array(user.union_id)
  end

  def sync_legacy_union(user)
    first_union_id = user.union_ids.first
    user.update_column(:union_id, first_union_id) if user.union_id != first_union_id
  end

  def available_unions
    return Union.order(:name) if current_user.super_admin?

    Union.where(id: current_user.union_ids_for_access).order(:name)
  end

  def normalize_union_ids(raw_ids)
    Array(raw_ids).reject(&:blank?).map(&:to_i)
  end
end
