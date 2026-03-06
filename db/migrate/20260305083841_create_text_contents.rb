class CreateTextContents < ActiveRecord::Migration[7.1]
  def change
    create_table :text_contents do |t|
      t.text :body
      t.references :course_list_section, null: false, foreign_key: true

      t.timestamps
    end
  end
end
