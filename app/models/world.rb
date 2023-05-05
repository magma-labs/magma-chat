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
#  world_id    :uuid             not null
#
# Indexes
#
#  index_things_on_type      (type)
#  index_things_on_world_id  (world_id)
#
class World < Thing
  attribute :world_id, :uuid, default: -> { "00000000-0000-0000-0000-000000000000" }
  has_many :things

  delegate_missing_to :instance

  def instance
    self.class.instance
  end

  def to_subject_name
    "World: #{id}"
  end

  def self.instance
    @instance ||= first_or_create!(name: "World") do |world|
      world.description = "The World"
    end
  end
end
