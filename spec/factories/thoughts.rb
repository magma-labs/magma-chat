FactoryBot.define do
  factory :thought do
    brief { Faker::Hipster.sentence }
    importance { 10 }
    type { 'Thought' }

    content { {content_key: 'content_value'} }

    association :bot
  end

  factory :observation, parent: :thought do
    type { 'Observation' }
  end
end
