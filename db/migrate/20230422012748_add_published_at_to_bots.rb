class AddPublishedAtToBots < ActiveRecord::Migration[7.0]
  def change
    add_column :bots, :published_at, :timestamp
    add_index :bots, :published_at
    rename_column :bots, :properties, :settings
  end
end
