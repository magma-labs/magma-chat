class AddPublicToChats < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :public_access, :boolean, default: false, null: false
    add_index :chats, :public_access
  end
end
