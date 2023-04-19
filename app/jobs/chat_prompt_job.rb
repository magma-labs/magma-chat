class ChatPromptJob < ApplicationJob
  def perform(chat, message, visible)
    Gpt.chat(directive: chat.directive, prompt: message, transcript: chat.messages_for_gpt).then do |reply|
      chat.bot_replied!(reply, visible)
    end
    # todo: error handling
  end
end
