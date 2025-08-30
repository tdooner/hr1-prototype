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

ActiveRecord::Schema[8.0].define(version: 2025_08_30_200815) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "engagement_forms", force: :cascade do |t|
    t.string "user_name"
    t.string "email"
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_job"
    t.boolean "is_student"
    t.boolean "enrolled_work_program"
    t.boolean "volunteers_nonprofit"
    t.text "job_details"
    t.text "student_details"
    t.text "work_program_details"
    t.text "volunteer_details"
    t.boolean "completed"
  end

  create_table "volunteer_shifts", force: :cascade do |t|
    t.bigint "engagement_form_id", null: false
    t.string "organization_name"
    t.date "shift_date"
    t.decimal "hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["engagement_form_id"], name: "index_volunteer_shifts_on_engagement_form_id"
  end

  add_foreign_key "volunteer_shifts", "engagement_forms"
end
