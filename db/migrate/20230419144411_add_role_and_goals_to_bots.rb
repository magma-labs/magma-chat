class AddRoleAndGoalsToBots < ActiveRecord::Migration[7.0]
  def change
    add_column :bots, :role, :string
    add_column :bots, :goals, :jsonb, default: [], null: false
    add_column :bots, :image_url, :string
    rename_column :bots, :description, :intro
  end
end
