class AddQuizCompletedAtToCourseCompletions < ActiveRecord::Migration[7.1]
  def change
    add_column :course_completions, :quiz_completed_at, :datetime
  end
end
