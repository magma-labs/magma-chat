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
