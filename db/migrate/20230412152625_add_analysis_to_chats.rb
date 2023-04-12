class AddAnalysisToChats < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :analysis, :jsonb, null: false, default: {}
  end
end
