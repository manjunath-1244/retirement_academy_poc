class FrontpageContent < ApplicationRecord
  has_one_attached :overview_video

  validates :hero_title, :hero_subtitle, :how_it_works, :header_text, :footer_text,
            :overview_title, :overview_subtitle, :overview_body, :learning_panel_title, presence: true

  def self.current
    first_or_create!
  end
end
