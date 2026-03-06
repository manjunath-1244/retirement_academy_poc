class CreateFrontpageContents < ActiveRecord::Migration[7.1]
  def change
    create_table :frontpage_contents do |t|
      t.string :hero_title, null: false, default: "Retirement Academy"
      t.text :hero_subtitle, null: false, default: "A learning platform for union members to complete retirement readiness courses."
      t.text :how_it_works, null: false, default: "1. Sign in with your account.\n2. Open your assigned union courses.\n3. Complete sections and track your progress."
      t.string :header_text, null: false, default: "Retirement Academy"
      t.string :footer_text, null: false, default: "Built for union learning and course completion tracking."

      t.timestamps
    end
  end
end
