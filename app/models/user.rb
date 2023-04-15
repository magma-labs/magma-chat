class User < ApplicationRecord
  has_many :chats, dependent: :destroy

  def self.from_omniauth(auth)
    auth.deep_symbolize_keys!
    where(oauth_provider: auth[:provider], oauth_uid: auth[:uid]).first_or_create do |user|
      user.name = auth[:info][:name]
      user.email = auth[:info][:email]
      user.image_url = auth[:info][:image]
      user.oauth_token = auth[:credentials][:token]
      user.oauth_expires_at = Time.at(auth[:credentials][:expires_at])
    end
  end

  def self.default
    where(name: "Default User").first_or_create do |user|
      user.email = "info@magmalabs.io"
      user.oauth_provider = "default"
      user.oauth_uid = "default"
    end
  end
end
