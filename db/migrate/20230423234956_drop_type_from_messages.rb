class DropTypeFromMessages < ActiveRecord::Migration[7.0]
  def change
    remove_column :messages, :type, :string, null: false, default: "Message"
  end
end
