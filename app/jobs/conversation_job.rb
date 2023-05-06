class ConversationJob < ApplicationJob
  queue_as :high_priority_queue

  attr_reader :conversation

  delegate :bot, :bot_message!,
           :messages_for_gpt,
           :user, :user_message!,
           to: :conversation

  def perform(conversation, content, visible)
    @conversation = conversation
    if bot.long_term_memory?
      # create both placeholders in the right order
      memories_message = user_message!("", visible: false)
      message = bot_message!("", visible: true)
      # add relevant memories from long term vector storage
      MemoryAnnotator.new(conversation, memories_message).perform(number_of_messages_to_pop: bot.ltm_recent_messages_count)
    else
      # create a blank assistant message to so that it shows thinking animation and keeps the order of messages correctly
      message = bot_message!("", visible: true)
    end

    # calculate maximum tokens to ask for in response
    tokens_count = TikToken.count(conversation.directive + content)

    opts = {
      model: conversation.model,
      directive: conversation.directive,
      prompt: content,
      max_tokens: conversation.max_tokens,
      temperature: conversation.temperature,
      top_p: conversation.top_p,
      presence_penalty: conversation.presence_penalty,
      frequency_penalty: conversation.frequency_penalty,
      transcript: messages_for_gpt(tokens_count + conversation.max_tokens),
      stream: user.streaming && stream_proc(message: message)
    }

    Gpt.chat(**opts).then do |reply|
      if reply.nil? # streaming
        ObservationJob.perform_later(observation) if bot.enable_observations?
        AnalysisJob.perform_later(observation) if conversation.enable_analysis?
      else
        message.update!(content: reply, run_analysis_after_saving: true)
      end
      # todo: proper error handling
    end
  end

  private

  def stream_proc(message:)
    proc do |chunk, _bytesize|
      new_content = chunk.dig("choices", 0, "delta", "content")
      message.update(content: message.content + new_content) if new_content
    end
  end
end
