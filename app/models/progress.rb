class Progress < ApplicationRecord
  belongs_to :user
  belongs_to :course_list_section

  validates :user_id, uniqueness: { scope: :course_list_section_id }
end
