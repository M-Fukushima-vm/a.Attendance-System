# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200628104913) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "month_approval", default: 0, null: false
    t.integer "approval_superior"
    t.integer "apply_month"
    t.datetime "t_started_at"
    t.datetime "t_finished_at"
    t.boolean "next_day", default: false
    t.integer "edit_approval", default: 0, null: false
    t.integer "e_approval_superior"
    t.datetime "overtime"
    t.integer "overtime_approval", default: 0, null: false
    t.integer "o_approval_superior"
    t.string "gyoumu_syori"
    t.datetime "sonohi_teiji"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "assortment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logs", force: :cascade do |t|
    t.date "hiduke"
    t.datetime "b_started_at"
    t.datetime "b_finished_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "syouninbi"
    t.integer "jyoucyou"
    t.integer "attendance_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_id"], name: "index_logs_on_attendance_id"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2020-07-17 23:00:00"
    t.datetime "work_time", default: "2020-07-17 22:30:00"
    t.string "affiliation"
    t.integer "employee_number"
    t.string "uid"
    t.datetime "basic_work_time", default: "2020-07-17 23:00:00"
    t.datetime "designed_work_start_time", default: "2020-07-18 00:00:00"
    t.datetime "designed_work_end_time", default: "2020-07-18 09:00:00"
    t.boolean "superior", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
