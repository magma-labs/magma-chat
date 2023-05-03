class DropEngineFromChats < ActiveRecord::Migration[7.1]
  def change
    remove_column :chats, :engine, :string, null: false
  end
end
