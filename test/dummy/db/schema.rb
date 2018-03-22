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

ActiveRecord::Schema.define(version: 20150424090312) do

  create_table "referer_trackings", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type",              limit: 255
    t.text     "session_referer_url"
    t.text     "session_first_url"
    t.text     "current_request_url"
    t.text     "current_request_referer_url"
    t.string   "user_agent",                  limit: 255
    t.string   "ip",                          limit: 255
    t.string   "session_id",                  limit: 255
    t.text     "cookies_yaml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "request_added",               limit: 255
    t.string   "session_added",               limit: 255
    t.text     "cookie_referer_url"
    t.text     "cookie_first_url"
    t.datetime "cookie_time"
    t.text     "infos_session"
    t.text     "infos_request"
    t.text     "log"
    t.string   "status"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
