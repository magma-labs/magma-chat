class AddGrowToChats < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :grow, :boolean, null: false, default: false
  end
end
