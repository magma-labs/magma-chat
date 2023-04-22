# == Schema Information
#
# Table name: messages
#
#  id               :uuid             not null, primary key
#  content          :text
#  properties       :jsonb            not null
#  rating           :integer          default(0), not null
#  role             :string
#  sender_image_url :string
#  sender_name      :string
#  sender_type      :string
#  tokens_count     :integer          default(0), not null
#  type             :string           default("Message"), not null
#  visible          :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  chat_id          :uuid             not null
#  sender_id        :uuid
#
# Indexes
#
#  index_messages_on_chat_id  (chat_id)
#  index_messages_on_role     (role)
#  index_messages_on_sender   (sender_type,sender_id)
#  index_messages_on_type     (type)
#
# Foreign Keys
#
#  fk_rails_...  (chat_id => chats.id)
#
FactoryBot.define do
  factory :message do
    role { 'user' }
    content { Faker::Hipster.sentence }

    association :chat
  end
end
