class CreateUnions < ActiveRecord::Migration[7.1]
  def change
    create_table :unions do |t|
      t.string :name
      t.string :subdomain
      t.string :contact_email

      t.timestamps
    end
  end
end
