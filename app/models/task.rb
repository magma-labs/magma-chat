# == Schema Information
#
# Table name: things
#
#  id          :uuid             not null, primary key
#  description :text             default(""), not null
#  name        :string           not null
#  settings    :jsonb            not null
#  type        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_things_on_type  (type)
#
class Task < ApplicationRecord
end
