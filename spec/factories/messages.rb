FactoryBot.define do
  factory :message do
    role { 'user' }
    content { Faker::Hipster.sentence }

    association :chat
  end
end
