class CreateCourseListSections < ActiveRecord::Migration[7.1]
  def change
    create_table :course_list_sections do |t|
      t.string :title
      t.integer :position
      t.references :course_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
