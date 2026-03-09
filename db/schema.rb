# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_03_09_090000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "course_completions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_list_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_list_id"], name: "index_course_completions_on_course_list_id"
    t.index ["user_id", "course_list_id"], name: "index_course_completions_on_user_id_and_course_list_id", unique: true
    t.index ["user_id"], name: "index_course_completions_on_user_id"
  end

  create_table "course_list_sections", force: :cascade do |t|
    t.string "title"
    t.integer "position"
    t.bigint "course_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_list_id"], name: "index_course_list_sections_on_course_list_id"
  end

  create_table "course_lists", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
  end

  create_table "frontpage_contents", force: :cascade do |t|
    t.string "hero_title", default: "Retirement Academy", null: false
    t.text "hero_subtitle", default: "A learning platform for union members to complete retirement readiness courses.", null: false
    t.text "how_it_works", default: "1. Sign in with your account.\n2. Open your assigned union courses.\n3. Complete sections and track your progress.", null: false
    t.string "header_text", default: "Retirement Academy", null: false
    t.string "footer_text", default: "Built for union learning and course completion tracking.", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "overview_title", default: "Course overview", null: false
    t.text "overview_subtitle", default: "Review the Retirement Academy introductory content.", null: false
    t.text "overview_body", default: "Welcome to the Retirement Academy. This curriculum is designed to help you make the most of your employer retirement plan. Let’s get started.", null: false
    t.string "learning_panel_title", default: "Get started learning.", null: false
  end

  create_table "images", force: :cascade do |t|
    t.string "title"
    t.string "image_url"
    t.bigint "course_list_section_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["course_list_section_id"], name: "index_images_on_course_list_section_id"
  end

  create_table "progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_list_section_id", null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_list_section_id"], name: "index_progresses_on_course_list_section_id"
    t.index ["user_id", "course_list_section_id"], name: "index_progresses_on_user_id_and_course_list_section_id", unique: true
    t.index ["user_id"], name: "index_progresses_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "question"
    t.text "answer"
    t.bigint "course_list_section_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_list_section_id"], name: "index_reviews_on_course_list_section_id"
  end

  create_table "text_contents", force: :cascade do |t|
    t.text "body"
    t.bigint "course_list_section_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_list_section_id"], name: "index_text_contents_on_course_list_section_id"
  end

  create_table "union_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "union_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["union_id"], name: "index_union_memberships_on_union_id"
    t.index ["user_id", "union_id"], name: "index_union_memberships_on_user_id_and_union_id", unique: true
    t.index ["user_id"], name: "index_union_memberships_on_user_id"
  end

  create_table "unions", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "union_id"
    t.string "role", default: "member"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["union_id"], name: "index_users_on_union_id"
  end

  create_table "videos", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.bigint "course_list_section_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["course_list_section_id"], name: "index_videos_on_course_list_section_id"
  end

  create_table "visible_to_unions", force: :cascade do |t|
    t.bigint "union_id", null: false
    t.bigint "course_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_list_id"], name: "index_visible_to_unions_on_course_list_id"
    t.index ["union_id", "course_list_id"], name: "index_visible_to_unions_on_union_id_and_course_list_id", unique: true
    t.index ["union_id"], name: "index_visible_to_unions_on_union_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "course_completions", "course_lists"
  add_foreign_key "course_completions", "users"
  add_foreign_key "course_list_sections", "course_lists"
  add_foreign_key "images", "course_list_sections"
  add_foreign_key "progresses", "course_list_sections"
  add_foreign_key "progresses", "users"
  add_foreign_key "reviews", "course_list_sections"
  add_foreign_key "text_contents", "course_list_sections"
  add_foreign_key "union_memberships", "unions"
  add_foreign_key "union_memberships", "users"
  add_foreign_key "users", "unions"
  add_foreign_key "videos", "course_list_sections"
  add_foreign_key "visible_to_unions", "course_lists"
  add_foreign_key "visible_to_unions", "unions"
end
