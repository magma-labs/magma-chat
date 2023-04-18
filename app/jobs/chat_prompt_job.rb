class ChatPromptJob < ApplicationJob
  def perform(chat, message, visible)
    Gpt.chat(directive: chat.directive, prompt: message, transcript: chat.messages_for_gpt).then do |reply|
      if visible
        chat.run_analysis_after_saving = true
        chat.transcript += [{ role: "assistant", content: reply }]
      end
      chat.save!
    end
    # todo: error handling
  end
end
