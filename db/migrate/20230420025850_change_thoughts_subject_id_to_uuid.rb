class ChangeThoughtsSubjectIdToUuid < ActiveRecord::Migration[7.0]
  def change
    remove_column :thoughts, :subject_id, :bigint
    add_column :thoughts, :subject_id, :uuid
    add_index :thoughts, [:subject_type, :subject_id], name: 'index_thoughts_on_subject'
  end
end
