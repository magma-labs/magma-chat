# == Schema Information
#
# Table name: tools
#
#  id             :uuid             not null, primary key
#  implementation :text
#  name           :string           not null
#  settings       :jsonb            not null
#  type           :string           default("Tool"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  bot_id         :uuid             not null
#
# Indexes
#
#  index_tools_on_bot_id  (bot_id)
#  index_tools_on_type    (type)
#
# Foreign Keys
#
#  fk_rails_...  (bot_id => bots.id)
#
class Tool < ApplicationRecord
end
