class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :union, optional: true
  has_many :union_memberships, dependent: :destroy
  has_many :unions, through: :union_memberships

  has_many :progresses, dependent: :destroy
  has_many :course_completions, dependent: :destroy

  ROLES = %w[member admin super_admin].freeze
  ASSIGNABLE_ROLES = %w[member admin].freeze

  validates :role, inclusion: { in: ROLES }

  def admin?
    role == "admin" || role == "super_admin"
  end

  def super_admin?
    role == "super_admin"
  end

  def union_ids_for_access
    ids = unions.pluck(:id)
    ids = [union_id] if ids.empty? && union_id.present?
    ids
  end
end
