class CreateVisibleToUnions < ActiveRecord::Migration[7.1]
  def change
    create_table :visible_to_unions do |t|
      t.references :union, null: false, foreign_key: true
      t.references :course_list, null: false, foreign_key: true

      t.timestamps
    end

    add_index :visible_to_unions, [:union_id, :course_list_id], unique: true
  end
end
