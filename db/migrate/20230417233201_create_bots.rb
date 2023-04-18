class CreateBots < ActiveRecord::Migration[7.0]
  def change
    create_table :bots, id: :uuid do |t|
      t.string :name, null: false, index: true
      t.text :directive, null: false, default: ""
      t.text :description
      t.integer :auto_archive_mins, null: false, default: 0
      t.integer :chats_count, null: false, default: 0
      t.timestamps
    end

    # add optional bot_id to chats
    add_reference :chats, :bot, type: :uuid, index: true
  end
end
