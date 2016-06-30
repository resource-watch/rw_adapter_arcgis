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

ActiveRecord::Schema.define(version: 20160616110304) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "citext"

  create_table "datasets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.jsonb    "data_columns", default: "{}"
    t.integer  "data_horizon", default: 0
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["data_columns"], name: "index_datasets_on_data_columns", using: :gin
  end

  create_table "service_settings", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "token"
    t.string   "url"
    t.boolean  "listener"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_service_settings_on_name", unique: true, using: :btree
  end

end
