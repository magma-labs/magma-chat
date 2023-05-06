# == Schema Information
#
# Table name: users
#
#  id                  :uuid             not null, primary key
#  admin               :boolean          default(FALSE), not null
#  conversations_count :integer          default(0), not null
#  email               :string           not null
#  image_url           :string
#  name                :string           default(""), not null
#  oauth_expires_at    :datetime
#  oauth_provider      :string           not null
#  oauth_token         :string
#  oauth_uid           :string           not null
#  settings            :jsonb            not null
#  type                :string           default("Human"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class User < ApplicationRecord
  include Settings

  def self.from_omniauth(auth)
    auth.deep_symbolize_keys!
    where(oauth_provider: auth[:provider], oauth_uid: auth[:uid]).first_or_create do |user|
      user.name = auth[:info][:name]
      user.email = auth[:info][:email]
      user.image_url = auth[:info][:image]
      user.oauth_token = auth[:credentials][:token]
      user.oauth_expires_at = Time.at(auth[:credentials][:expires_at])
    end.tap do |user|
      # keep image up to date
      if auth[:info][:image] != user.image_url
        user.update(image_url: auth[:info][:image])
      end
    end
  end

  # todo: probably not needed anymore
  def self.default
    where(name: "Default User").first_or_create do |user|
      user.email = "info@magmalabs.io"
      user.oauth_provider = "default"
      user.oauth_uid = "default"
    end
  end
end
