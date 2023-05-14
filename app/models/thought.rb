# == Schema Information
#
# Table name: thoughts
#
#  id           :uuid             not null, primary key
#  brief        :string           not null
#  content      :jsonb            not null
#  importance   :integer          default(50), not null
#  subject_type :string
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bot_id       :uuid             not null
#  subject_id   :uuid
#
# Indexes
#
#  index_thoughts_on_bot_id   (bot_id)
#  index_thoughts_on_brief    (brief)
#  index_thoughts_on_subject  (subject_type,subject_id)
#
class Thought < ApplicationRecord
  include Vectorable

  attribute :subject_name, :string

  belongs_to :bot
  belongs_to :subject, polymorphic: true, optional: true

  enable_cable_ready_updates

  scope :by_bot, ->(bot) { where(bot: bot) }
  scope :by_user, ->(user) { where(subject: user) }

  scope :by_decayed_score, -> {
    # assigns a higher score to memory objects that were recently created so that events from a moment ago or this morning are likely to remain in the agent’s attentional sphere
    select("thoughts.*, ROUND(POW(2, (-EXTRACT(EPOCH FROM (NOW() - created_at)) / 2592000)) * ((importance - 10) / 90.0) * 100, 2) as decayed_score").order("decayed_score DESC")
  }

  before_create :create_new_subject, if: :subject_name?

  # brief should be unique per bot and subject
  validates :brief, presence: true, uniqueness: { scope: %i[type bot_id subject_id subject_type] }

  def brief_with_timestamp
    "[#{created_at.strftime('%d/%m/%Y %H:%M')}] #{brief.strip.gsub(/\.$/,"")}"
  end

  def to_partial_path
    "thoughts/#{self.class.name.underscore}"
  end

  protected

  def non_tensor_fields
    [:type, :bot_id, :subject_id, :subject_type, :importance]
  end

  def vector_fields
    content.merge(attributes.symbolize_keys.slice(:type, :brief, :bot_id, :subject_id, :subject_type, :importance))
  end

  private

  def create_new_subject
    return if subject_id?
    raise "Cannot create new subject with name and no type" if subject_type.blank?
    self.subject = subject_type.constantize.create!(name: subject_name)
  end
end
