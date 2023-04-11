class InitializeSchema < ActiveRecord::Migration[7.0]
  create_table :conversations, id: :uuid do |t|
    t.string :title, null: false, index: true
    t.string :engine, null: false, index: true
    t.jsonb :transcript, null: false, default: []
    t.timestamps
  end
end
