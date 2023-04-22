class AddTokensToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :tokens_count, :integer, null: false, default: 0
  end
end
