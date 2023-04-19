class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages, id: :uuid do |t|
      t.string :type, index: true, null: false, default: "Message"
      t.references :chat, type: :uuid, null: false, foreign_key: true, index: true
      t.references :sender, type: :uuid, null: true, polymorphic: true, index: true
      t.string :role, index: true
      t.text :content
      t.string :sender_name
      t.string :sender_image_url
      t.jsonb :properties, default: {}, null: false
      t.integer :rating, default: 0, null: false
      t.boolean :visible, null: false, default: true
      t.timestamps
    end
  end
end
