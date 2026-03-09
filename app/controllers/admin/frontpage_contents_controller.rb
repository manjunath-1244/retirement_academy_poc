class Admin::FrontpageContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :require_super_admin

  def edit
    @frontpage = FrontpageContent.current
  end

  def update
    @frontpage = FrontpageContent.current

    if @frontpage.update(frontpage_params)
      redirect_to edit_admin_frontpage_content_path, notice: "Front page updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def frontpage_params
    params.require(:frontpage_content).permit(
      :hero_title,
      :hero_subtitle,
      :how_it_works,
      :header_text,
      :footer_text,
      :overview_title,
      :overview_subtitle,
      :overview_body,
      :learning_panel_title,
      :overview_video
    )
  end
end
