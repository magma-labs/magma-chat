# == Schema Information
#
# Table name: conversations
#
#  id                   :uuid             not null, primary key
#  analysis             :jsonb            not null
#  grow                 :boolean          default(FALSE), not null
#  last_analysis_at     :datetime
#  last_observations_at :datetime
#  public_access        :boolean          default(FALSE), not null
#  settings             :jsonb            not null
#  title                :string           not null
#  transcript           :jsonb            not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  bot_id               :uuid
#  user_id              :uuid             default("b48d0808-271f-451e-a190-8610009df363"), not null
#
# Indexes
#
#  index_conversations_on_bot_id         (bot_id)
#  index_conversations_on_public_access  (public_access)
#  index_conversations_on_title          (title)
#  index_conversations_on_user_id        (user_id)
#
class Conversation < ApplicationRecord
  include PgSearch::Model
  include Settings

  attribute :first_message

  # TODO: Placeholder for flipping conversations to private, move to settings later
  attribute :off_the_record, :boolean, default: false

  belongs_to :bot, optional: true, counter_cache: true
  # todo: rename to owner or initiator because there will be multiple participants in a single convo
  belongs_to :user, counter_cache: true

  has_many :messages, dependent: :destroy, enable_cable_ready_updates: true
  has_one :latest_message, -> { visible.order(created_at: :desc) }, class_name: "Message"

  before_create :set_title
  before_create :copy_settings_from_bot
  after_create :add_context_messages

  after_commit :prompt!, on: :create, if: :first_message

  enable_cable_ready_updates on: [:update]

  pg_search_scope :search_tags, against: :analysis,
    using: { tsearch: { prefix: true } }

  delegate :directive, to: :bot

  def analysis
    text = super
    if text.kind_of? String
      JSON.parse(text).deep_symbolize_keys
    else
      text.deep_symbolize_keys
    end
  end

  def bot
    super || Bot.default
  end

  def bot_id
    super || Bot.default.id
  end

  def bot_observations!(observations)
    return if observations.blank?
    bot.observations.create!(observations.map {|o| { subject: user, brief: o } })
  end

  def label
    "a conversation between #{user.name} and #{bot.name}, #{bot.role}"
  end

  def latest_message_content
    latest_message&.content
  end

  def prompt!(message: first_message, visible: true, sender: user)
    Rails.logger.info("USER PROMPT: #{message}")
    user_message!(message, visible: messages.any?, skip_broadcast: false).tap do |um|
      if bot.enable_shared_messages? && !off_the_record
        MessageRememberJob.set(wait: 1.minute).perform_later(um)
      end
    end
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

  def tags
    analysis[:tags] || []
  end

  def total_token_count
    messages.sum(:tokens_count)
  end

  ##
  # Returns the last messages exchanged in this conversation
  # in format suitable for GPT's chat completion API
  #
  # @param tokens_in_prompt [Integer] the number of tokens in the directive and user prompt (Default: nil)
  # @param token_limit [Integer] the maximum number of tokens to return (Default: 2000)
  # @param only_visible [Boolean] whether to return only visible messages (Default: false)
  # @param since [Symbol, Time] the time to start from (Default: nil)
  # @return [Array<Hash>] an array of hashes with role and content keys
  def messages_for_gpt(tokens_in_prompt: nil, token_limit: 2000, only_visible: false, since:  nil)
    # don't blow the context window limitation of the model
    if tokens_in_prompt
      model_max_tokens = model["gpt-4"] ? 8000 : 4000
      token_limit = model_max_tokens - tokens_in_prompt
    end
    query = Message
    if since
      since = send(since) if since.kind_of?(Symbol)
      query = query.where("created_at > ?", since)
    end
    query.up_to_token_limit(self, token_limit, only_visible: only_visible).map do |message|
      next if message.content.blank? # skip empty messages
      { role: message.role, content: message.content }
    end.compact # remove nils
  end

  def analysis_next
    analysis[:next] || []
  end

  # todo: replace this with throw/catch or exception handling so that it stops the original completion
  def reprompt_with_human_override!(message)
    # grab the last two visible messages in correct order
    last_messages = self.messages.reload.latest.limit(3).to_a.reverse
    prompt = Magma::Prompts.get("conversations.reprompt_with_human_override", {
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

  def display_settings!
    messages.create!(role: "settings", skip_broadcast: true)
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
    # at least for the moment, this is the way that short term memory is implemented
    # so if the bot doesn't have short term memory, we don't need this routine
    return unless bot.short_term_memory?
    # if the bot is talking to the user for the first time, there will be no context
    # todo: this will change once a bot has memory of conversations with other users
    # that it is allowed to use to inform its conversation with a new user
    return if bot.conversations.where(user_id: user.id).empty?

    context_intro_prompt = Magma::Prompts.get("conversations.context_intro",
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
      context_memories_prompt = Magma::Prompts.get("conversations.context_memories", { m: top_memories.join("\n\n"), lang: user.preferred_language })
      user_message!(context_memories_prompt, skip_broadcast: true, visible: false)
      context_reply = Magma::Prompts.get("conversations.context_memories_reply", lang: user.preferred_language)
      bot_message!(context_reply, skip_broadcast: true, visible: false)
    end
  end

  def copy_settings_from_bot
    self.model = bot.model
    self.temperature = bot.temperature
    self.top_p = bot.top_p
    self.presence_penalty = bot.presence_penalty
    self.frequency_penalty = bot.frequency_penalty
    self.max_tokens = bot.max_tokens
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
