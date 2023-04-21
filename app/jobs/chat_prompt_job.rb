class ChatPromptJob < ApplicationJob
  queue_as :high_priority_queue

  def perform(chat, content, visible)
    # create a blank assistant message to so that it shows
    # thinking animation and keeps the order of messages correctly
    message = chat.messages.create(
      sender: chat.bot,
      role: "assistant",
      content: "",
      visible: visible,
      run_analysis_after_saving: false
    )

    max_tokens = [200, content.length * 2].max
    Gpt.chat(directive: chat.directive,
             prompt: content,
             max_tokens: max_tokens,
             transcript: chat.messages_for_gpt).then do |reply|
      message.update!(content: reply, run_analysis_after_saving: true)
    end
    # todo: error handling, probably put it into the message content
  end
end
