# == Schema Information
#
# Table name: users
#
#  id               :uuid             not null, primary key
#  admin            :boolean          default(FALSE), not null
#  chats_count      :integer          default(0), not null
#  email            :string           not null
#  image_url        :string
#  name             :string           default(""), not null
#  oauth_expires_at :datetime
#  oauth_provider   :string           not null
#  oauth_token      :string
#  oauth_uid        :string           not null
#  settings         :jsonb            not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
FactoryBot.define do
  factory :user do
    admin { false }
    email { Faker::Internet.email }
    name { Faker::Name.name }

    oauth_uid { Faker::Number.number(digits: 9).to_s }
    oauth_provider { 'google_oauth2' }

    image_url { Faker::Internet.url }
  end

  factory :admin, parent: :user do
    admin { true }
  end
end
