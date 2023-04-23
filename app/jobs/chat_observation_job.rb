class ChatObservationJob < ApplicationJob
  queue_as :default

  def perform(chat)
    directive = Prompts.get("act_as_computer")
    prompt = Prompts.get("chats.consider")
    tokens_count = TikToken.count(directive + prompt)
    Gpt.chat(
      directive: directive,
      prompt: prompt,
      transcript: chat.messages_for_gpt(tokens_count + 200, only_visible: true).take(6),
      temperature: 0.5,
      max_tokens: 300,
    ).then do |response|
      if response.blank?
        Rails.logger.warn "😵😵😵 No response to observation for Chat: #{chat.id}"
      else
        puts
        puts "🔥🔥🔥 #{response} 🔥🔥🔥"
        puts
        json_match = response.match(/.*?(\{.*\})/m)
        if json_match
          JSON.parse(json_match[1], symbolize_names: true).then do |data|
            chat.bot.observed!(chat, data[:observations])
          end
        else
          Rails.logger.warn "😵😵😵 No observation for Chat: #{chat.id}"
          Rails.logger.warn "😵😵😵 GPT said: #{response}"
        end
      end
    end
  end
end
