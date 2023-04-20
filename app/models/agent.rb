# == Schema Information
#
# Table name: bots
#
#  id                :uuid             not null, primary key
#  auto_archive_mins :integer          default(0), not null
#  chats_count       :integer          default(0), not null
#  directive         :text             default(""), not null
#  goals             :jsonb            not null
#  image_url         :string
#  intro             :text
#  name              :string           not null
#  properties        :jsonb            not null
#  role              :string
#  type              :string           default("Bot"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_bots_on_name  (name)
#  index_bots_on_type  (type)
#
class Agent < Bot
  list_to_text :goals
end
