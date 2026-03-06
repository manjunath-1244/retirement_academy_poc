class AddDescriptionToVideosAndImages < ActiveRecord::Migration[7.1]
  def change
    add_column :videos, :description, :text
    add_column :images, :description, :text
  end
end
