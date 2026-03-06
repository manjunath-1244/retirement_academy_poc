class AddUnionToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :union, null: true, foreign_key: true
  end
end
