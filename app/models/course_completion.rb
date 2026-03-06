class CourseCompletion < ApplicationRecord
  belongs_to :user
  belongs_to :course_list

  validates :user_id, uniqueness: { scope: :course_list_id }
end
