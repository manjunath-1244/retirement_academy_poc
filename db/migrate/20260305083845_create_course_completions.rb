class CreateCourseCompletions < ActiveRecord::Migration[7.1]
  def change
    create_table :course_completions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course_list, null: false, foreign_key: true
      t.datetime :completed_at

      t.timestamps
    end

    add_index :course_completions, [:user_id, :course_list_id], unique: true
  end
end
