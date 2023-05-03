FactoryBot.define do
  factory :bot do
    goals { {} }
    name { Faker::Name.name }
    settings { {} }
  end
end
