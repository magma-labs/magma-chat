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
  INDEX = :thoughts

  belongs_to :bot
  belongs_to :subject, polymorphic: true, optional: true

  scope :latest, -> { order(created_at: :desc) }
  scope :by_bot, ->(bot) { where(bot: bot) }
  scope :by_user, ->(user) { where(subject: user) }

  scope :by_decayed_score, -> {
    # assigns a higher score to memory objects that were recently created so that events from a moment ago or this morning are likely to remain in the agent’s attentional sphere
    select("thoughts.*, ROUND(POW(2, (-EXTRACT(EPOCH FROM (NOW() - created_at)) / 2592000)) * ((importance - 10) / 90.0) * 100, 2) as decayed_score").order("decayed_score DESC")
  }

  after_commit :store_vector, on: %i[create update]
  after_commit :delete_vector, on: %i[destroy]

  # brief should be unique per bot and subject
  validates :brief, presence: true, uniqueness: { scope: %i[type bot_id subject_id subject_type] }

  def brief_with_timestamp
    "[#{created_at.strftime('%d/%m/%Y %H:%M')}]:#{brief.strip.gsub(/\.$/,"")}"
  end

  private

  def store_vector
    fields = attributes.symbolize_keys.slice(:type, :brief, :bot_id, :subject_id, :subject_type, :importance)
    document = content.merge(fields)
    Marqo.client.store(
      index: INDEX, id: id, doc: document,
      non_tensor_fields: [:type, :bot_id, :subject_id, :subject_type, :importance]
    )
  rescue
    Rails.logger.error("Failed to store vector for thought #{id}")
  end

  def delete_vector
    Marqo.client.delete(INDEX, id)
  rescue
    Rails.logger.error("Failed to delete vector for thought #{id}")
  end
end
