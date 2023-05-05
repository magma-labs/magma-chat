class CreateThings < ActiveRecord::Migration[7.1]
  def change
    create_table :things, id: :uuid do |t|
      t.uuid :world_id, null: false, index: true
      t.string :name, null: false
      t.string :type, null: false, index: true
      t.text :description, null: false, default: ""
      t.jsonb :settings, null: false, default: {}
      t.timestamps
    end
  end
end
