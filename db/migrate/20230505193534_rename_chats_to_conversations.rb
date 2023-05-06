class RenameChatsToConversations < ActiveRecord::Migration[7.1]
  def change
    rename_table :chats, :conversations
    rename_column :bots, :chats_count, :conversations_count
    rename_column :users, :chats_count, :conversations_count
    rename_column :messages, :chat_id, :conversation_id
  end
end
