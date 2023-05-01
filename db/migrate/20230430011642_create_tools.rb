class CreateTools < ActiveRecord::Migration[7.0]
  def change
    create_table :tools, id: :uuid do |t|
      t.references :bot, type: :uuid, null: false, foreign_key: true, index: true
      t.string :type, null: false, index: true, default: 'Tool'
      t.string :name, null: false
      t.text :implementation
      t.jsonb :settings, null: false, default: {}
      t.timestamps
    end
  end
end
