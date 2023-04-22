class ChatObservationJob < ApplicationJob
  queue_as :default

  def perform(chat)
    Gpt.chat(
      directive: Prompts.get("act_as_computer"),
      prompt: Prompts.get("chats.consider"),
      transcript: chat.messages_for_gpt.last(6),
      temperature: 0.2
    ).then do |json|
      if json.blank?
        Rails.logger.warn "No JSON found in GPT response to observation for Chat: #{chat.id}"
      else
        puts
        puts "🔥🔥🔥 #{json} 🔥🔥🔥"
        puts
        JSON.parse(json.match(/.*?(\{.*\})/m)[1], symbolize_names: true).then do |data|
          chat.bot.observed!(chat, data[:observations])
        end
      end
    end
  end
end
