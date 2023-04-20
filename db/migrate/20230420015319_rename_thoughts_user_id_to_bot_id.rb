class RenameThoughtsUserIdToBotId < ActiveRecord::Migration[7.0]
  def change
    rename_column :thoughts, :user_id, :bot_id
  end
end
