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
#  chat_id          :uuid             not null
#  sender_id        :uuid
#
# Indexes
#
#  index_messages_on_chat_id  (chat_id)
#  index_messages_on_role     (role)
#  index_messages_on_sender   (sender_type,sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_id => chats.id)
#
class Message < ApplicationRecord
  include PgSearch::Model
  include Strategic

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
  before_save :set_sender
  before_update :override_disclaimers, if: -> { role.assistant? }

  after_commit :broadcast_message, on: :create, unless: :skip_broadcast
  after_commit :reanalyze, if: :run_analysis_after_saving

  validates :role, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  def broadcast_message
    return if role.assistant?
    ChatPromptJob.perform_later(chat, content, visible)
  end

  # todo: consider setting automatically based on sender type
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

  def to_partial_path
    "messages/message"
  end

  def self.up_to_token_limit(chat, max_tokens, only_visible:)
    subquery =
      select("*, SUM(tokens_count) OVER (ORDER BY created_at DESC) AS running_total")
        .where(chat_id: chat.id, visible: [true, only_visible])
        .from("messages")
        .to_sql

    select("*")
      .from("(#{subquery}) AS subquery")
      .where("running_total <= ?", max_tokens)
      .order("subquery.created_at desc")
      .to_a
      .reverse
  end

  def reanalyze
    ChatObservationJob.perform_later(chat) if chat.bot.enable_observations?
    ChatAnalysisJob.perform_later(chat) if chat.enable_analysis?
  end

  private

  def calculate_tokens
    self.tokens_count = TikToken.count(content.to_s.encode('UTF-8', 'UTF-8', invalid: :replace, undef: :replace))
  end

  def override_disclaimers
    return unless content.present? && chat.bot.humanize?
    # todo: can we make this work in user's language not just English?
    regex = Regexp.new(Prompts.get("disclaimers").join("|"))
    if match = content.match(regex)
      self.visible = false
      chat.reprompt_with_human_override!(self)
    end
  end

  def strategy_name
    role
  end
end
