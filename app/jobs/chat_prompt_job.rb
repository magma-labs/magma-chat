class ChatPromptJob < ApplicationJob
  queue_as :high_priority_queue

  def perform(chat, content, visible)
    # add relevant memories from long term vector storage
    MemoryAnnotator.new(chat).perform

    # create a blank assistant message to so that it shows
    # thinking animation and keeps the order of messages correctly
    message = chat.messages.create(role: "assistant", content: "", visible: visible, run_analysis_after_saving: false)

    # calculate maximum tokens to ask for in response
    tokens_count = TikToken.count(chat.directive + content)
    max_tokens = chat.settings.response_length_tokens

    # chat options
    opts = {
      directive: chat.directive,
      prompt: content,
      max_tokens: max_tokens,
      temperature: 0.7,
      transcript: chat.messages_for_gpt(tokens_count + max_tokens),
      stream: chat.user.settings.streaming && stream_proc(message: message)
    }

    # make sure to never pull only visible here, or we will lose consideration of memories
    reply = Gpt.chat(**opts)

    # todo: need a different way of handling toolchain, so this is getting taken out soon
    if reply.nil? # streaming
      ChatObservationJob.perform_later(chat)
      ChatAnalysisJob.perform_later(chat)
      ChatResponsibilityJob.perform_later(chat)
    else
      process_reply_with_toolchain(chat, message, reply)
    end

    # todo: error handling, probably put it into the message content
  end

  private

  def stream_proc(message:)
    proc do |chunk, _bytesize|
      new_content = chunk.dig("choices", 0, "delta", "content")
      message.update(content: message.content + new_content) if new_content
    end
  end

  ## TODO: WIP (Having a hard time getting bot to recognize what tools it can use.)
  def process_reply_with_toolchain(chat, message, reply)
    # Example of a toolchain directive:
    # [GoogleSearch]: { "question": "What is the current population of Paris?" }
    directive_regex = /\[([A-Z][a-zA-Z]+)\]: (\{.+?\})/
    directives = reply.scan(directive_regex)

    if directives.any?
      directives_string = ""
      directives.each do |directive|
        tool_name = directive[0]
        json_object = JSON.parse(directive[1])
        tool_name.constantize.perform_later(chat, json_object)
        directives_string += "[#{tool_name}]: #{json_object.to_s}\n\n"
      end

      reply_without_directives = reply.gsub(directive_regex, "").strip
      if reply_without_directives.present?
        # bot included some extra commentary along with its tool invocations, so put them in the chat
        message.update!(content: reply_without_directives, run_analysis_after_saving: true)
        # keep the toolchain directives in a separate invisible message
        chat.bot_message!(directives_string, visible: false, run_analysis_after_saving: false)
      else
        message.update!(content: directives_string, visible: false, run_analysis_after_saving: false)
      end
    else
      # no directives just add bot reply to chat as usual
      message.update!(content: reply, run_analysis_after_saving: true)
    end
  end
end
