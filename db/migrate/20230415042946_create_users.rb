class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name, null: false, default: ""
      t.string :email, null: false
      t.string :image_url
      t.string :oauth_uid, null: false
      t.string :oauth_provider, null: false
      t.string :oauth_token
      t.datetime :oauth_expires_at
      t.integer :chats_count, default: 0, null: false
      t.timestamps
    end
  end
end
