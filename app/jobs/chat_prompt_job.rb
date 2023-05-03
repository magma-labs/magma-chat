class ChatPromptJob < ApplicationJob
  queue_as :high_priority_queue

  def perform(chat, content, visible)
    if chat.bot.long_term_memory?
      # create both placeholders in the right order
      memories_message = chat.user_message!("", visible: false)
      message = chat.bot_message!("", visible: true)
      # add relevant memories from long term vector storage
      MemoryAnnotator.new(chat, memories_message).perform(number_of_messages_to_pop: chat.bot.ltm_recent_messages_count)
    else
      # create a blank assistant message to so that it shows thinking animation and keeps the order of messages correctly
      message = chat.bot_message!("", visible: true)
    end

    # calculate maximum tokens to ask for in response
    tokens_count = TikToken.count(chat.directive + content)


    # chat options
    opts = {
      model: chat.model,
      directive: chat.directive,
      prompt: content,
      max_tokens: chat.max_tokens,
      temperature: chat.temperature,
      top_p: chat.top_p,
      presence_penalty: chat.presence_penalty,
      frequency_penalty: chat.frequency_penalty,
      transcript: chat.messages_for_gpt(tokens_count + chat.max_tokens),
      stream: chat.user.streaming && stream_proc(message: message)
    }

    Gpt.chat(**opts).then do |reply|
      if reply.nil? # streaming
        ChatObservationJob.perform_later(chat) if chat.bot.enable_observations?
        ChatAnalysisJob.perform_later(chat) if chat.enable_analysis?
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
