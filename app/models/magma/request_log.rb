# == Schema Information
#
# Table name: request_logs
#
#  id                :uuid             not null, primary key
#  completion_tokens :integer          default(0), not null
#  duration_seconds  :integer          default(0), not null
#  label             :string           default(""), not null
#  model             :string           default(""), not null
#  operation         :string           default(""), not null
#  prompt_tokens     :integer          default(0), not null
#  request           :jsonb            not null
#  response          :jsonb            not null
#  total_tokens      :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :uuid             not null
#
# Indexes
#
#  index_request_logs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Magma::RequestLog < ApplicationRecord
  self.table_name = "request_logs"
end
