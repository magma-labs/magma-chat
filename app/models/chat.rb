# == Schema Information
#
# Table name: chats
#
#  id            :uuid             not null, primary key
#  analysis      :jsonb            not null
#  engine        :string           not null
#  grow          :boolean          default(FALSE), not null
#  public_access :boolean          default(FALSE), not null
#  settings      :jsonb            not null
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
  include Settings

  attribute :first_message

  belongs_to :bot, optional: true, counter_cache: true
  belongs_to :user # todo: rename to owner or initiator

  has_many :messages, dependent: :destroy, enable_cable_ready_updates: true

  before_create :set_title
  after_create :add_context_messages

  after_commit :prompt!, on: :create, if: :first_message

  enable_cable_ready_updates on: [:update]

  pg_search_scope :search_tags, against: :analysis,
    using: { tsearch: { prefix: true } }

  delegate :directive, to: :bot

  def analysis
    super.deep_symbolize_keys
  end

  def bot
    super || Bot.default
  end

  def bot_id
    super || Bot.default.id
  end

  def prompt!(message: first_message, visible: true, sender: user)
    Rails.logger.info("USER PROMPT: #{message}")
    user_message!(message, visible: visible, skip_broadcast: false)
  end

  def redo!(sender, message)
    messages.by_bots.last.destroy
    last_prompt = messages.by_user(sender).last.destroy
    prompt!(message: message.presence || last_prompt.content, sender: sender)
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

  def total_token_count
    messages.sum(:tokens_count)
  end

  def messages_for_gpt(tokens_in_prompt, only_visible: false)
    puts
    puts "tokens_in_prompt: #{tokens_in_prompt}"
    puts
    max_tokens = 1500 - tokens_in_prompt # todo: move to setting or constant
    Message.up_to_token_limit(self, max_tokens, only_visible: only_visible).map do |message|
      { role: message.role, content: message.content }
    end
  end

  def analysis_next
    analysis[:next] || []
  end

  # todo: replace this with throw/catch or exception handling so that it stops the original completion
  def reprompt_with_human_override!(message)
    # grab the last two visible messages in correct order
    last_messages = self.messages.reload.latest.limit(3).to_a.reverse
    prompt = Prompts.get("chats.reprompt_with_human_override", {
      bot_role: bot.role,
      bot_message: last_messages.first.content,
      user_message: last_messages.second.content
    })
    Gpt.chat(prompt: prompt, temperature: 1.2).then do |response|
      puts
      puts "😇😇😇 #{response}"
      puts
      message.update!(content: response, visible: true)
    end
  end

  def tags
    analysis[:tags].presence || []
  end

  def bot_message!(content, run_analysis_after_saving: false, skip_broadcast: true, visible: false)
    messages.create!(role: "assistant", content: content, skip_broadcast: skip_broadcast, run_analysis_after_saving: run_analysis_after_saving, visible: visible)
  end

  def user_message!(content, run_analysis_after_saving: false, skip_broadcast: true, visible: false)
    messages.create!(role: "user", content: content, skip_broadcast: skip_broadcast, visible: visible)
  end

  private

  def add_context_messages
    context_intro_prompt = Prompts.get("chats.context_intro",
      bot_name: bot.name,
      bot_role: bot.role,
      user_name: user.name,
      user_id: user.id,
      date: Date.today.strftime("%B %d, %Y"),
      time: Time.now.strftime("%I:%M %p"),
      timezone: "US/Central" # todo: just send localized time instead of UTC so we don't have issues with daylight savings, etc
    )

    user_message!(context_intro_prompt, skip_broadcast: true, visible: false)

    top_memories = bot.top_memories_of(user)
    if top_memories.any?
      context_memories_prompt = Prompts.get("chats.context_memories", { m: top_memories.join("\n\n"), lang: user.settings.preferred_language })
      user_message!(context_memories_prompt, skip_broadcast: true, visible: false)
      context_reply = Prompts.get("chats.context_memories_reply", lang: user.settings.preferred_language)
      bot_message!(context_reply, skip_broadcast: true, visible: false)
    end
  end

  def set_title
    if first_message.blank?
      self.title = "Conversation with #{bot.name}"
    else
      self.title = first_message
    end
  end

  def prefix_timestamp_to_content(message)
    "[#{message.updated_at.strftime("%m/%d/%y %I:%M %p")}] #{message.content}"
  end

end
