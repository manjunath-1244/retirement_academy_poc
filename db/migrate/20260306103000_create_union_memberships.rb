class CreateUnionMemberships < ActiveRecord::Migration[7.1]
  def up
    create_table :union_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :union, null: false, foreign_key: true

      t.timestamps
    end

    add_index :union_memberships, [:user_id, :union_id], unique: true

    execute <<~SQL
      INSERT INTO union_memberships (user_id, union_id, created_at, updated_at)
      SELECT id, union_id, NOW(), NOW()
      FROM users
      WHERE union_id IS NOT NULL
    SQL
  end

  def down
    drop_table :union_memberships
  end
end
