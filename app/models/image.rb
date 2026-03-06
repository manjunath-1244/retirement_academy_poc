class Image < ApplicationRecord
  belongs_to :course_list_section
  has_one_attached :file

  validates :title, presence: true
  validate :file_must_be_attached

  private

  def file_must_be_attached
    errors.add(:file, "must be attached") unless file.attached?
  end
end
