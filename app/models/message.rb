# == Schema Information
#
# Table name: messages
#
#  id               :uuid             not null, primary key
#  content          :text
#  properties       :jsonb            not null
#  rating           :integer          default(0), not null
#  role             :string
#  sender_image_url :string
#  sender_name      :string
#  sender_type      :string
#  type             :string           default("Message"), not null
#  visible          :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  chat_id          :uuid             not null
#  sender_id        :uuid
#
# Indexes
#
#  index_messages_on_chat_id  (chat_id)
#  index_messages_on_role     (role)
#  index_messages_on_sender   (sender_type,sender_id)
#  index_messages_on_type     (type)
#
# Foreign Keys
#
#  fk_rails_...  (chat_id => chats.id)
#
class Message < ApplicationRecord
  include PgSearch::Model

  attribute :run_analysis_after_saving, :boolean, default: false

  belongs_to :chat
  belongs_to :sender, polymorphic: true, optional: true

  scope :by_bots, -> { where(role: "assistant") }
  scope :by_users, -> { where(role: "user") }
  scope :by_user, ->(user) { where(sender: user) }

  pg_search_scope :search_content, against: [:content]

  after_commit :broadcast_message, on: :create
  after_commit :reanalyze, if: :run_analysis_after_saving

  validates :role, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  def broadcast_message
    if role.user?
      ChatPromptJob.perform_later(chat, content, visible)
    end
  end

  def role
    super.to_s.inquiry
  end

  def sender=(sender)
    super
    self.sender_name = sender.name
    self.sender_image_url = sender.image_url
  end

  private

  def reanalyze
    ChatAnalysisJob.perform_later(chat)
  end

end
