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

ActiveRecord::Schema.define(version: 20160117135432) do

  create_table "intents", force: true do |t|
    t.string   "qid"
    t.string   "iid"
    t.string   "content"
    t.string   "type"
    t.float    "probability"
    t.integer  "query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "intents", ["query_id"], name: "index_intents_on_query_id"

  create_table "iunits", force: true do |t|
    t.string   "qid"
    t.string   "uid"
    t.text     "content"
    t.float    "importance"
    t.string   "type"
    t.integer  "query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "iunits", ["query_id"], name: "index_iunits_on_query_id"

  create_table "judges", force: true do |t|
    t.string   "qid"
    t.string   "iid"
    t.string   "uid"
    t.float    "importance"
    t.string   "type"
    t.integer  "query_id"
    t.integer  "intent_id"
    t.integer  "iunit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "judges", ["intent_id"], name: "index_judges_on_intent_id"
  add_index "judges", ["iunit_id"], name: "index_judges_on_iunit_id"
  add_index "judges", ["query_id"], name: "index_judges_on_query_id"

  create_table "queries", force: true do |t|
    t.string   "qid"
    t.string   "content"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "runs", force: true do |t|
    t.integer  "runtype"
    t.string   "run_file"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_name"
    t.boolean  "agree"
    t.string   "type"
    t.text     "description"
    t.boolean  "is_open"
  end

  add_index "runs", ["user_id"], name: "index_runs_on_user_id"

end
