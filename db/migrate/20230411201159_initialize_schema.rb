class InitializeSchema < ActiveRecord::Migration[7.0]
  def change
    create_table :chats, id: :uuid do |t|
      t.string :title, null: false, index: true
      t.string :engine, null: false, index: true
      t.jsonb :transcript, null: false, default: []
      t.timestamps
    end
  end
end
