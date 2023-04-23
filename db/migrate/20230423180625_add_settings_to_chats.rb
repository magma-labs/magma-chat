class AddSettingsToChats < ActiveRecord::Migration[7.0]
  def change
    # add settings JSONB to users
    add_column :chats, :settings, :jsonb, default: { response_length_tokens: 400, show_invisibles: false }, null: false
  end
end
