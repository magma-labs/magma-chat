class AddSettingsToUsers < ActiveRecord::Migration[7.0]
  def change
    # add settings JSONB to users
    add_column :users, :settings, :jsonb, default: { preferred_language: "English" }, null: false
  end
end
