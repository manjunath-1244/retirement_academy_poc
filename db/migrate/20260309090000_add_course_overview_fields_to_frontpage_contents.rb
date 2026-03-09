class AddCourseOverviewFieldsToFrontpageContents < ActiveRecord::Migration[7.1]
  def change
    add_column :frontpage_contents, :overview_title, :string, null: false, default: "Course overview"
    add_column :frontpage_contents, :overview_subtitle, :text, null: false, default: "Review the Retirement Academy introductory content."
    add_column :frontpage_contents, :overview_body, :text, null: false, default: "Welcome to the Retirement Academy. This curriculum is designed to help you make the most of your employer retirement plan. Let’s get started."
    add_column :frontpage_contents, :learning_panel_title, :string, null: false, default: "Get started learning."
  end
end
