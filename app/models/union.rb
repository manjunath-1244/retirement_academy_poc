class Union < ApplicationRecord
  has_many :union_memberships, dependent: :destroy
  has_many :users, through: :union_memberships
  has_many :visible_to_unions, dependent: :destroy
  has_many :course_lists, through: :visible_to_unions
end
