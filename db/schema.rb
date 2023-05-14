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

ActiveRecord::Schema[7.1].define(version: 2023_05_14_052436) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "directive", default: "", null: false
    t.text "intro"
    t.integer "auto_archive_mins", default: 0, null: false
    t.integer "conversations_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", default: "Bot", null: false
    t.jsonb "settings", default: {}, null: false
    t.string "role"
    t.jsonb "goals", default: [], null: false
    t.string "image_url"
    t.datetime "published_at", precision: nil
    t.index ["name"], name: "index_bots_on_name"
    t.index ["published_at"], name: "index_bots_on_published_at"
    t.index ["type"], name: "index_bots_on_type"
  end

  create_table "conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.jsonb "transcript", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "analysis", default: {}, null: false
    t.boolean "grow", default: false, null: false
    t.uuid "user_id", default: "b48d0808-271f-451e-a190-8610009df363", null: false
    t.uuid "bot_id"
    t.boolean "public_access", default: false, null: false
    t.jsonb "settings", default: {"show_invisibles"=>false, "response_length_tokens"=>400}, null: false
    t.datetime "last_analysis_at", precision: nil
    t.datetime "last_observations_at", precision: nil
    t.index ["bot_id"], name: "index_conversations_on_bot_id"
    t.index ["public_access"], name: "index_conversations_on_public_access"
    t.index ["title"], name: "index_conversations_on_title"
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "conversation_id", null: false
    t.string "sender_type"
    t.uuid "sender_id"
    t.string "role"
    t.text "content"
    t.string "sender_name"
    t.string "sender_image_url"
    t.jsonb "properties", default: {}, null: false
    t.integer "rating", default: 0, null: false
    t.boolean "visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tokens_count", default: 0, null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["role"], name: "index_messages_on_role"
    t.index ["sender_type", "sender_id"], name: "index_messages_on_sender"
  end

  create_table "request_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "label", default: "", null: false
    t.string "operation", default: "", null: false
    t.string "model", default: "", null: false
    t.jsonb "request", default: {}, null: false
    t.jsonb "response", default: {}, null: false
    t.integer "prompt_tokens", default: 0, null: false
    t.integer "completion_tokens", default: 0, null: false
    t.integer "total_tokens", default: 0, null: false
    t.integer "duration_seconds", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_request_logs_on_user_id"
  end

  create_table "things", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "world_id", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.text "description", default: "", null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_things_on_type"
    t.index ["world_id"], name: "index_things_on_world_id"
  end

  create_table "thoughts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.uuid "bot_id", null: false
    t.string "subject_type"
    t.string "brief", null: false
    t.jsonb "content", default: {}, null: false
    t.integer "importance", default: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "subject_id"
    t.index ["bot_id"], name: "index_thoughts_on_bot_id"
    t.index ["brief"], name: "index_thoughts_on_brief"
    t.index ["subject_type", "subject_id"], name: "index_thoughts_on_subject"
  end

  create_table "tools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bot_id", null: false
    t.string "type", default: "Tool", null: false
    t.string "name", null: false
    t.text "implementation"
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bot_id"], name: "index_tools_on_bot_id"
    t.index ["type"], name: "index_tools_on_type"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", null: false
    t.string "image_url"
    t.string "oauth_uid", null: false
    t.string "oauth_provider", null: false
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.integer "conversations_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.jsonb "settings", default: {"preferred_language"=>"English"}, null: false
    t.string "type", default: "Human", null: false
  end

  add_foreign_key "messages", "conversations"
  add_foreign_key "request_logs", "users"
  add_foreign_key "tools", "bots"
end
