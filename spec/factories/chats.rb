# == Schema Information
#
# Table name: chats
#
#  id            :uuid             not null, primary key
#  analysis      :jsonb            not null
#  engine        :string           not null
#  grow          :boolean          default(FALSE), not null
#  public_access :boolean          default(FALSE), not null
#  settings      :jsonb            not null
#  title         :string           not null
#  transcript    :jsonb            not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  bot_id        :uuid
#  user_id       :uuid             default("b48d0808-271f-451e-a190-8610009df363"), not null
#
# Indexes
#
#  index_chats_on_bot_id         (bot_id)
#  index_chats_on_engine         (engine)
#  index_chats_on_public_access  (public_access)
#  index_chats_on_title          (title)
#  index_chats_on_user_id        (user_id)
#
FactoryBot.define do
  factory :chat do
    engine { 'engine' }
    analysis { {} }

    association :bot
    association :user

    transient do
      message_count { 0 }
    end

    after(:create) do |chat, evaluator|
      create_list(:message, evaluator.message_count, chat: chat)
    end
  end
end
