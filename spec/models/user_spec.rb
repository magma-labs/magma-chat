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
#  type             :string           default("Human"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#tag_cloud' do
    let(:chat) { create(:chat, analysis: { tags: tags }) }
    let(:instance) { chat.user }
    let(:tags) do
      [
        :tag_one,
        [ :tag_two, :tag_two ],
        [ :tag_three, :tag_three, :tag_three ]
      ]
    end

    before do
      allow(Gpt).to receive(:chat)
    end

    let(:expected_tags) do
      {
        tag_three: 3,
        tag_two: 2
      }.stringify_keys
    end

    it 'returns a hash with limited tag amount', :aggregate_failures do
      expect(instance.tag_cloud(limit: 2)).to eq expected_tags
    end
  end

  describe '.from_omniauth' do
    let(:auth) { Faker::Omniauth.facebook(name: Faker::Name.name) }
    let(:last_user) { User.last }

    it 'creates an user' do
      expect { described_class.from_omniauth(auth) }.to change(User, :count).by(1)

      expect(last_user.name).to eq auth.dig(:info, :name)
      expect(last_user.email).to eq auth.dig(:info, :email)
      expect(last_user.image_url).to eq auth.dig(:info, :image)
      expect(last_user.oauth_token).to eq auth.dig(:credentials, :token)
      expect(last_user.oauth_expires_at).to eq Time.at(auth.dig(:credentials, :expires_at))
    end
  end

  describe '.default' do
    let(:last_user) { User.last }

    it 'creates a default user', :aggregate_failures do
      expect { described_class.default }.to change(User, :count).by(1)

      expect(last_user.email).to eq 'info@magmalabs.io'
      expect(last_user.oauth_provider).to eq 'default'
      expect(last_user.oauth_uid).to eq 'default'
    end
  end
end
