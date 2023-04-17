class CreateThoughts < ActiveRecord::Migration[7.0]
  def change
    create_table :thoughts, id: :uuid do |t|
      # subclasses: Observation, Reflection, Plan
      t.string :type
      # scoped to user
      t.uuid :user_id, null: false, index: true
      # subject can be a chat or an agent or something else
      t.references :subject, polymorphic: true, index: true
      t.string :brief, null: false, index: true
      # content can be any other details we see fit to store,
      # including references to linked thoughts
      t.jsonb :content, null: false, default: {}
      # range: 0-100 used in retrieval function
      t.integer :importance, null: false, default: 50
      # timestamp is importance for recency parameter of retrieval function
      t.timestamps
    end
  end
end
