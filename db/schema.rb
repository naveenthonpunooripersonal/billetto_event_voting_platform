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

ActiveRecord::Schema[8.1].define(version: 2026_08_24_200047) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "event_store_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.jsonb "metadata"
    t.datetime "valid_at"
    t.index "COALESCE(valid_at, created_at)", name: "index_event_store_events_on_as_of"
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_on_event_id", unique: true
    t.index ["event_type"], name: "index_event_store_events_on_event_type"
    t.index ["valid_at"], name: "index_event_store_events_on_valid_at"
  end

  create_table "event_store_events_in_streams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.integer "position"
    t.string "stream", null: false
    t.index ["created_at"], name: "index_event_store_events_in_streams_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_in_streams_on_event_id"
    t.index ["stream", "event_id"], name: "index_event_store_events_in_streams_on_stream_and_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_events_in_streams_on_stream_and_position", unique: true
  end

  create_table "event_vote_counts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "dislikes_count", default: 0, null: false
    t.bigint "event_id", null: false
    t.integer "likes_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "event_vote_counts_on_event_id_index", unique: true
    t.index ["event_id"], name: "index_event_vote_counts_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.text "address"
    t.string "billetto_event_id", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "event_url", null: false
    t.string "image_url"
    t.datetime "start_date", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["billetto_event_id"], name: "index_events_on_billetto_event_id", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.string "vote_type", null: false
    t.index ["event_id", "user_id"], name: "index_votes_on_event_id_and_user_id", unique: true
    t.index ["event_id"], name: "index_votes_on_event_id"
  end

  add_foreign_key "event_store_events_in_streams", "event_store_events", column: "event_id", primary_key: "event_id"
  add_foreign_key "event_vote_counts", "events"
  add_foreign_key "votes", "events"
end
