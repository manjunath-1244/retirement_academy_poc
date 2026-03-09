class CourseList < ApplicationRecord
  has_many :course_list_sections, -> { order(:position, :id) }, dependent: :destroy
  has_many :course_quiz_questions, -> { order(:position, :id) }, dependent: :destroy
  has_many :course_completions, dependent: :destroy
  has_many :visible_to_unions, dependent: :destroy
  has_many :unions, through: :visible_to_unions
  accepts_nested_attributes_for :course_list_sections, allow_destroy: true
  accepts_nested_attributes_for :course_quiz_questions, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true

  before_create :assign_position

  private

  def assign_position
    return if position.present?

    self.position = (CourseList.maximum(:position) || 0) + 1
  end
end
