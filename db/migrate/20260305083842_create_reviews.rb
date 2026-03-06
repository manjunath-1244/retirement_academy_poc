class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.text :question
      t.text :answer
      t.references :course_list_section, null: false, foreign_key: true

      t.timestamps
    end
  end
end
