FactoryBot.define do
  factory :user do
    admin { false }
    email { Faker::Internet.email }
    name { Faker::Name.name }

    oauth_uid { Faker::Number.number(digits: 21) }
    oauth_provider { 'Google' }

    image_url { Faker::Internet.url }

    trait :admin do
      admin { true }
    end
  end
end
