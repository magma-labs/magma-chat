class AddTypeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :type, :string, null: false, default: "Human"
  end
end
