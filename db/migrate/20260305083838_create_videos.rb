class CreateVideos < ActiveRecord::Migration[7.1]
  def change
    create_table :videos do |t|
      t.string :title
      t.string :url
      t.references :course_list_section, null: false, foreign_key: true

      t.timestamps
    end
  end
end
