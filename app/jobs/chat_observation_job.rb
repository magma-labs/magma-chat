class ChatObservationJob < ApplicationJob
  queue_as :default

  def perform(chat)
    Gpt.chat(prompt: Prompts.get("chats.consider"), transcript: chat.messages_for_gpt.last(4)).then do |json|
      return if json.blank? # todo: error handling
      unless json.starts_with?("{") && json.end_with?("}")
        json = extract_json(json)
      end
      if json.blank?
        Rails.logger.warn "No JSON found in GPT response to observation for Chat: #{chat.id}"
      else
        JSON.parse(json, symbolize_names: true).then do |data|
          chat.bot.observed!(chat, data[:observations])
        end
      end
    end
  end
end
