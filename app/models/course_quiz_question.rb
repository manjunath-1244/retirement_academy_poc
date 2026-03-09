class CourseQuizQuestion < ApplicationRecord
  belongs_to :course_list

  validates :question, :option_one, :option_two, :option_three, :option_four, :answer_explanation, presence: true
  validates :correct_option, inclusion: { in: 1..4 }
  validates :position, numericality: { only_integer: true, allow_nil: true }

  before_validation :assign_position, on: :create

  def options
    {
      1 => option_one,
      2 => option_two,
      3 => option_three,
      4 => option_four
    }
  end

  private

  def assign_position
    return if position.present? || course_list.blank?

    self.position = (course_list.course_quiz_questions.maximum(:position) || 0) + 1
  end
end
