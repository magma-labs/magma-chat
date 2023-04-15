class AddUserIdToChats < ActiveRecord::Migration[7.0]
  def change
    add_reference :chats, :user, type: :uuid, index: true, null: false, default: -> { "'#{User.default.id}'" }
  end
end
