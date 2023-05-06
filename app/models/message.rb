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
#  visible          :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  conversation_id  :uuid             not null
#  sender_id        :uuid
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#  index_messages_on_role             (role)
#  index_messages_on_sender           (sender_type,sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (conversation_id => conversations.id)
#
class Message < ApplicationRecord
  include PgSearch::Model
  include Strategic

  attribute :run_analysis_after_saving, :boolean, default: false
  attribute :skip_broadcast, :boolean, default: false

  delegate :to_partial_path, to: :strategy
  delegate :bot, :user, to: :conversation

  belongs_to :conversation
  belongs_to :sender, polymorphic: true, optional: true

  scope :by_bots, -> { where(role: "assistant") }
  scope :by_users, -> { where(role: "user") }
  scope :by_user, ->(user) { where(sender: user) }

  # scope that filters out nil or empty content
  scope :with_content, -> { where.not(content: [nil, ""]) }

  pg_search_scope :search_content, against: [:content]

  before_update :override_disclaimers

  before_save :calculate_tokens
  before_save :set_sender

  after_commit :broadcast_message, on: :create, unless: :skip_broadcast
  after_commit :reanalyze, if: :run_analysis_after_saving

  validates :role, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  after_initialize do
    self.strategy ||= role.to_s
  end

  def reanalyze
    ObservationJob.perform_later(conversation) if bot.enable_observations?
    AnalysisJob.perform_later(conversation) if conversation.enable_analysis?
  end

  def role
    super.to_s.inquiry
  end

  def role=(r)
    super(r.to_s)
    self.strategy = r.to_s
  end

  def sender=(sender)
    super
    self.sender_name = sender.name
    self.sender_image_url = sender.image_url
  end

  def self.up_to_token_limit(conversation, max_tokens, only_visible:)
    subquery =
      select("*, SUM(tokens_count) OVER (ORDER BY created_at DESC) AS running_total")
        .where(conversation_id: conversation.id, visible: [true, only_visible], role: ["user", "assistant"])
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
end
