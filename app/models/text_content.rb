class TextContent < ApplicationRecord
  belongs_to :course_list_section

  validates :body, presence: true
end
