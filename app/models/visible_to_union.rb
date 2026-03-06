class VisibleToUnion < ApplicationRecord
  belongs_to :union
  belongs_to :course_list

  validates :union_id, uniqueness: { scope: :course_list_id }
end
