# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151009175754) do

  create_table "crono_jobs", force: :cascade do |t|
    t.string   "job_id",            null: false
    t.text     "log"
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "crono_jobs", ["job_id"], name: "index_crono_jobs_on_job_id", unique: true

  create_table "marks", force: :cascade do |t|
    t.string   "display_name",     limit: 255
    t.string   "email_addr",       limit: 255
    t.string   "notification_tag", limit: 255
    t.boolean  "complete_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "campaign",         limit: 255
    t.string   "hashid"
    t.boolean  "postnotify_flag",              default: false
  end

  create_table "stats", force: :cascade do |t|
    t.integer  "visit"
    t.boolean  "visit_lock"
    t.integer  "submission"
    t.boolean  "submission_lock"
    t.integer  "mark_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "valid_submission", default: false, null: false
  end

  add_index "stats", ["mark_id"], name: "index_stats_on_mark_id"

  create_table "visits", force: :cascade do |t|
    t.datetime "time"
    t.string   "location"
    t.string   "ua"
    t.string   "resource"
    t.string   "data"
    t.integer  "mark_id"
    t.boolean  "exception"
    t.string   "exception_exp"
    t.string   "campaign"
    t.boolean  "valid_submission", default: false, null: false
  end

  add_index "visits", ["mark_id"], name: "index_visits_on_mark_id"

end
