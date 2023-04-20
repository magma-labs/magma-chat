class ChatObservationJob < ApplicationJob
  def perform(chat)
    Gpt.chat(prompt: Prompts.get("chats.consider"), transcript: chat.messages_for_gpt.last(4)).then do |json|
      unless json.starts_with?("{") && json.end_with?("}")
        json = extract_json(json)
      end
      JSON.parse(json, symbolize_names: true).then do |data|
        chat.bot.observed!(chat, data[:observations])
      end
    end
  end
end
