class CreateCourseQuizQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :course_quiz_questions do |t|
      t.references :course_list, null: false, foreign_key: true
      t.text :question, null: false
      t.string :option_one, null: false
      t.string :option_two, null: false
      t.string :option_three, null: false
      t.string :option_four, null: false
      t.integer :correct_option, null: false
      t.text :answer_explanation, null: false
      t.integer :position

      t.timestamps
    end

    add_index :course_quiz_questions, [:course_list_id, :position]
  end
end
