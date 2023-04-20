class ChatPromptJob < ApplicationJob
  queue_as :high_priority_queue

  def perform(chat, message, visible)
    max_tokens = [200, message.length * 2].max
    Gpt.chat(directive: chat.directive,
             prompt: message,
             max_tokens: max_tokens,
             transcript: chat.messages_for_gpt).then do |reply|
      chat.bot_replied!(reply, visible)
    end
    # todo: error handling
  end
end
