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

  scope :by_bot, ->(bot) { where(bot: bot) }
  scope :by_user, ->(user) { where(subject: user) }

  after_commit :store_vector, on: %i[create update]
  after_commit :delete_vector, on: %i[destroy]

  def brief_with_timestamp
    "[#{created_at.strftime('%d/%m/%Y %H:%M')}]:#{brief.strip.gsub(/\.$/,"")}"
  end


  private

  def store_vector
    fields = attributes.slice(:type, :brief, :bot_id, :subject_id, :subject_type, :importance)
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
