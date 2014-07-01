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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140525105549) do

  create_table "referer_trackings", :force => true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.text     "session_referer_url"
    t.text     "session_first_url"
    t.text     "current_request_url"
    t.text     "current_request_referer_url"
    t.string   "user_agent"
    t.string   "ip"
    t.string   "session_id"
    t.text     "cookies_yaml"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "request_added"
    t.string   "session_added"
    t.text     "cookie_referer_url"
    t.text     "cookie_first_url"
    t.datetime "cookie_time"
    t.text     "infos_session"
    t.text     "infos_request"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
