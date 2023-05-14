# TODO: This entire monstrosity needs to be refactored into an object
class ConversationJob < ApplicationJob
  queue_as :high_priority_queue

  attr_reader :conversation

  delegate :bot, :bot_message!, :messages_for_gpt, :user, :user_message!,
   to: :conversation

  def perform(conversation, user_message_content, visible)
    @conversation = conversation

    if bot.humanize?
      user_message_content = roleplay_prefix(user_message_content)
    end

    if bot.long_term_memory?
      # create both placeholders in the right order
      memories_message = user_message!("", visible: false)
      message = bot_message!("", visible: true, responding_to: user_message_content)
      # add relevant memories from long term vector storage
      MemoryAnnotator.new(conversation, memories_message).perform(number_of_messages_to_pop: bot.ltm_recent_messages_count)
    else
      # create a blank assistant message to so that it shows thinking animation and keeps the order of messages correctly
      message = bot_message!("", visible: true, responding_to: user_message_content)
    end

    tokens_count = TikToken.count(conversation.full_directive + user_message_content)

    transcript = messages_for_gpt(tokens_in_prompt: tokens_count, only_visible: false)
    if bot.enable_shared_messages?
      MessageAnnotator.add_relevant_messages_to(conversation, transcript)
    end

    buffer = []

    chat = Magma::Chat.new(
      model: conversation.model,
      directive: conversation.full_directive,
      transcript: transcript,
      max_tokens: conversation.max_tokens,
      temperature: conversation.temperature,
      top_p: conversation.top_p,
      presence_penalty: conversation.presence_penalty,
      frequency_penalty: conversation.frequency_penalty,
      stream: user.streaming && stream_proc(message:) #StreamProcessor.new(buffer: buffer, message: message)
    )

    chat.prompt(content: user_message_content).then do |reply|
      if user.streaming
        message.update!(content: buffer.join) unless buffer.empty?
      else
        # streaming returns nil when the stream is closed
        message.update!(content: reply) unless reply.blank?
      end

      # todo: proper error handling
      ObservationJob.perform_later(conversation) if bot.enable_observations?
      AnalysisJob.perform_later(conversation) if conversation.enable_analysis?
    end

    if bot.enable_shared_messages?
      MessageRememberJob.set(wait: 1.minute).perform_later(message)
    end
  end

  FILTER_REGEX = Regexp.new(Magma::Prompts.get("disclaimers").join("|"))

  private

  def roleplay_prefix(content)
    "[MagmaChat System: As #{bot.label} how do you respond to #{user.name.split.first} saying: #{content}. Remember to stay in character always or you'll ruin the game!]"
  end

  # todo: change to cableready streaming and save once response is finished
  def stream_proc(message:)
    proc do |chunk, _bytesize|
      new_content = chunk.dig("choices", 0, "delta", "content")
      if new_content
        ActiveRecord::Base.logger.silence do
          message.update!(content: message.content + new_content)
        end
      end
    end
  end

  class StreamProcessor
    FILTER_REGEX = Regexp.new(Magma::Prompts.get("disclaimers").join("|"))

    def initialize(bot:, buffer:, message:)
      Rails.logger.info "💦💦💦 initializing stream processor for message: #{message} 💦💦💦"
      @buffer = buffer
      @message = message
    end

    def call(chunk, _bytesize)
      Rails.logger.info "💦💦💦 streaming chunk: #{chunk} (#{_bytesize} bytes) 💦💦💦"
      if new_content = chunk.dig("choices", 0, "delta", "content")
        @buffer << new_content
        ActiveRecord::Base.logger.silence do
          @message.update(content: @message.content + new_content)
        end

        raise "stopping non-humanized reply" if bot.humanize? && buffer.join.match?(FILTER_REGEX)
      end
    end
  end

end
