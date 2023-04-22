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
    tokens_count = TikToken.count(chat.directive + content)
    Gpt.chat(directive: chat.directive,
             prompt: content,
             max_tokens: 500,
             transcript: chat.messages_for_gpt(tokens_count)).then do |reply|
      message.update!(content: reply, run_analysis_after_saving: true)
    end
    # todo: error handling, probably put it into the message content
  end
end
