class ChatPromptJob < ApplicationJob
  def perform(chat, message)
    Gpt.chat(prompt: message, transcript: chat.transcript).then do |response|
      chat.transcript += [{ role: "assistant", content: response }]
      chat.save!
    end
    # todo: error handling
  end
end
