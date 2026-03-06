class AddPositionToCourseLists < ActiveRecord::Migration[7.1]
  def up
    add_column :course_lists, :position, :integer

    CourseList.reset_column_information
    CourseList.order(:created_at, :id).each_with_index do |course, index|
      course.update_column(:position, index + 1)
    end
  end

  def down
    remove_column :course_lists, :position
  end
end
