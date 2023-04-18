class AddTypeToBots < ActiveRecord::Migration[7.0]
  def change
    add_column :bots, :type, :string, null: false, default: "Bot"
    add_column :bots, :properties, :jsonb, null: false, default: {}

    add_index :bots, :type
  end
end
