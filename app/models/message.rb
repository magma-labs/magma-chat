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
#  tokens_count     :integer          default(0), not null
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
  attribute :skip_broadcast, :boolean, default: false

  belongs_to :chat
  belongs_to :sender, polymorphic: true, optional: true

  scope :by_bots, -> { where(role: "assistant") }
  scope :by_users, -> { where(role: "user") }
  scope :by_user, ->(user) { where(sender: user) }

  # scope that filters out nil or empty content
  scope :with_content, -> { where.not(content: [nil, ""]) }

  pg_search_scope :search_content, against: [:content]

  before_save :calculate_tokens

  after_commit :broadcast_message, on: :create, unless: :skip_broadcast
  after_commit :reanalyze, if: :run_analysis_after_saving

  validates :role, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  def broadcast_message
    if role.user?
      ChatPromptJob.perform_later(chat, content, visible)
    end
  end

  # todo: consider setting automatically based on sender type
  def role
    super.to_s.inquiry
  end

  def sender=(sender)
    super
    self.sender_name = sender.name
    self.sender_image_url = sender.image_url
  end

  def self.up_to_token_limit(chat, max_tokens)
    subquery =
      select("*, SUM(tokens_count) OVER (ORDER BY created_at DESC) AS running_total")
        .where(chat_id: chat.id)
        .from("messages")
        .to_sql

    select("*")
      .from("(#{subquery}) AS subquery")
      .where("running_total <= ?", max_tokens)
      .order("subquery.created_at desc")
      .to_a
      .reverse
  end

  private

  def calculate_tokens
    self.tokens_count = TikToken.count(content.to_s.encode('UTF-8', 'UTF-8', invalid: :replace, undef: :replace))
  end

  def reanalyze
    # after 2 messages, then every 4th message
    if chat.messages.length % 4 == 2
      ChatObservationJob.perform_later(chat)
    end
    if chat.messages.length % 6 == 4
      ChatAnalysisJob.perform_later(chat)
    end
  end

end
