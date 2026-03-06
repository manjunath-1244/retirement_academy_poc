class CourseListSection < ApplicationRecord
  belongs_to :course_list

  has_many :videos, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :text_contents, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :progresses, dependent: :destroy

  accepts_nested_attributes_for :videos, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :text_contents, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :position, numericality: { only_integer: true, allow_nil: true }
end
