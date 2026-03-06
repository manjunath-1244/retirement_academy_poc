class Admin::UnionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :require_super_admin
  before_action :set_union, only: [:show, :edit, :update, :destroy]

  def index
    @unions = Union.order(:name)
  end

  def show; end

  def new
    @union = Union.new
  end

  def create
    @union = Union.new(union_attributes)
    @union.user_ids = allowed_user_ids_from_params

    if @union.save
      sync_legacy_union_ids_for(allowed_user_ids_from_params)
      redirect_to admin_union_path(@union), notice: "Union created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    affected_user_ids = (@union.user_ids + allowed_user_ids_from_params).uniq

    @union.assign_attributes(union_attributes)
    @union.user_ids = allowed_user_ids_from_params

    if @union.save
      sync_legacy_union_ids_for(affected_user_ids)
      redirect_to admin_union_path(@union), notice: "Union updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    affected_user_ids = @union.user_ids
    @union.destroy
    sync_legacy_union_ids_for(affected_user_ids)

    redirect_to admin_unions_path, notice: "Union deleted successfully."
  end

  private

  def set_union
    @union = Union.find(params[:id])
  end

  def union_attributes
    params.require(:union).permit(:name, :subdomain, :contact_email)
  end

  def allowed_user_ids_from_params
    allowed_user_ids = User.where(role: User::ASSIGNABLE_ROLES).pluck(:id)
    Array(params.dig(:union, :user_ids)).reject(&:blank?).map(&:to_i)
                                              .select { |id| allowed_user_ids.include?(id) }
  end

  def sync_legacy_union_ids_for(user_ids)
    User.where(id: user_ids).find_each do |user|
      user.update_column(:union_id, user.union_ids.first)
    end
  end
end
