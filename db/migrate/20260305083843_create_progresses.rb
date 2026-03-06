class CreateProgresses < ActiveRecord::Migration[7.1]
  def change
    create_table :progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course_list_section, null: false, foreign_key: true
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :progresses, [:user_id, :course_list_section_id], unique: true
  end
end
