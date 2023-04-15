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

ActiveRecord::Schema[7.0].define(version: 2023_04_15_045433) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "engine", null: false
    t.jsonb "transcript", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "analysis", default: {}, null: false
    t.boolean "grow", default: false, null: false
    t.uuid "user_id", default: "b48d0808-271f-451e-a190-8610009df363", null: false
    t.index ["engine"], name: "index_chats_on_engine"
    t.index ["title"], name: "index_chats_on_title"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", null: false
    t.string "image_url"
    t.string "oauth_uid", null: false
    t.string "oauth_provider", null: false
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.integer "chats_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
