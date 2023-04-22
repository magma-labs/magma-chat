class ChatAnalysisJob < ApplicationJob
  queue_as :default

  def perform(chat)
    Gpt.chat(prompt: Prompts.get("chats.analyze", lang: chat.user.settings.preferred_language), transcript: chat.messages_for_gpt).then do |json|
      puts
      puts "🔥🔥🔥 #{json} 🔥🔥🔥"
      puts
      JSON.parse(json.match(/.*?(\{.*\})/m)[1], symbolize_names: true).then do |data|
        Rails.logger.info(data)
        chat.title = data[:title] if data[:title]
        chat.analysis = chat.analysis.merge(data)
        chat.save!
      end
    end
  end
end
