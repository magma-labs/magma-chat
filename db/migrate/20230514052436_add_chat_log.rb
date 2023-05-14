class AddChatLog < ActiveRecord::Migration[7.1]
  def change
    # user_id:uuid label request:jsonb response:jsonb prompt_tokens:integer completion_tokens:integer total_tokens:integer
    create_table :request_logs, id: :uuid do |t|
      t.references :user, foreign_key: true, null: false, type: :uuid, index: true
      t.string :label, null: false, default: ""
      t.string :operation, null: false, default: ""
      t.string :model, null: false, default: ""
      t.jsonb :request, null: false, default: {}
      t.jsonb :response, null: false, default: {}
      t.integer :prompt_tokens, null: false, default: 0
      t.integer :completion_tokens, null: false, default: 0
      t.integer :total_tokens, null: false, default: 0
      t.integer :duration_seconds, null: false, default: 0
      t.timestamps
    end
  end
end
