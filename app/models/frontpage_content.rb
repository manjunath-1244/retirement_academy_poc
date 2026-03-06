class FrontpageContent < ApplicationRecord
  validates :hero_title, :hero_subtitle, :how_it_works, :header_text, :footer_text, presence: true

  def self.current
    first_or_create!
  end
end
