class AddTimestampsToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :last_analysis_at, :timestamp
    add_column :conversations, :last_observations_at, :timestamp
  end
end
