# == Schema Information
#
# Table name: chats
#
#  id            :uuid             not null, primary key
#  analysis      :jsonb            not null
#  engine        :string           not null
#  grow          :boolean          default(FALSE), not null
#  public_access :boolean          default(FALSE), not null
#  title         :string           not null
#  transcript    :jsonb            not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  bot_id        :uuid
#  user_id       :uuid             default("b48d0808-271f-451e-a190-8610009df363"), not null
#
# Indexes
#
#  index_chats_on_bot_id         (bot_id)
#  index_chats_on_engine         (engine)
#  index_chats_on_public_access  (public_access)
#  index_chats_on_title          (title)
#  index_chats_on_user_id        (user_id)
#
class Chat < ApplicationRecord
  include PgSearch::Model

  attribute :first_message

  belongs_to :bot, optional: true, counter_cache: true
  belongs_to :user # todo: rename to owner or initiator

  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy, enable_cable_ready_updates: true

  before_create :set_title
  after_create :add_context_messages

  after_commit :prompt!, on: :create, if: :first_message
  #after_commit :reindex, on: :update

  enable_cable_ready_updates on: [:update]

  pg_search_scope :search_tags, against: :analysis,
    using: { tsearch: { prefix: true } }

  def analysis
    super.deep_symbolize_keys
  end

  def bot
    super || Bot.default
  end

  def bot_id
    super || Bot.default.id
  end

  def bot_replied!(content, visible)
    messages.create(sender: bot, role: "assistant", content: content, visible: visible, run_analysis_after_saving: true)
  end

  def directive
    bot.directive
  end

  def prompt!(message: first_message, visible: true, sender: user)
    Rails.logger.info("PROMPT: #{message}")
    messages.create(sender: sender, role: "user", content: message, visible: visible)
  end

  def redo!(sender, message)
    messages.by_bots.last.destroy
    last_prompt = messages.by_user(sender).last.destroy
    prompt!(message: message.presence || last_prompt.content, sender: sender)
  end

  def reindex
    # todo: reconsider whether every message should be store in marqo
    # ChatReindexJob.perform_later(self)
  end

  def language
    analysis[:language]
  end

  def sentiment
    analysis[:sentiment]
  end

  def summary
    analysis[:summary]
  end

  def messages_for_gpt
    messages.map do |message|
      { role: message.role, content: message.content }
    end
  end

  def analysis_next
    analysis[:next] || []
  end

  def tags
    analysis[:tags].presence || []
  end

  private

  def add_context_messages
    prompts = Prompts.get("chats.context_user", {
      bot_name: bot.name,
      user_name: user.name,
      date: Date.today.strftime("%B %d, %Y"),
      time: Time.now.strftime("%I:%M %p")
    })
    top_memories = bot.top_memories_of(user)
    if top_memories.any?
      prompts += Prompts.get("chats.context_top_memories", { m: top_memories.to_sentence })
    end
    messages.create(
      sender: user, role: "user",
      content: prompts,
      skip_broadcast: true,
      visible: false
    )
    messages.create(
      sender: bot, role: "assistant",
      content: Prompts.get("chats.context_reply"),
      skip_broadcast: true,
      visible: false
    )
  end

  def set_title
    if first_message.blank?
      self.title = "Conversation with #{bot.name}"
    else
      self.title = first_message
    end
  end

end
