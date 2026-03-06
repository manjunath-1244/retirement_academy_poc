class Review < ApplicationRecord
  belongs_to :course_list_section

  validates :question, :answer, presence: true
end
