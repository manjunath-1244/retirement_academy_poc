class UnionMembership < ApplicationRecord
  belongs_to :user
  belongs_to :union

  validates :user_id, uniqueness: { scope: :union_id }
end
