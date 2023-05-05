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
class Human < User
  include UsedAsSubject

  has_many :chats, dependent: :destroy, foreign_key: :user_id
  has_many :messages, as: :sender

  def tag_cloud(limit: 70)
    tag_counts = Hash.new(0)
    chats.select(:analysis).map(&:tags).flatten.each do |tag|
      tag_counts[tag] += 1
    end
    tag_counts.sort_by {|k, v| v}.reverse.take(limit).to_h
  end

end
