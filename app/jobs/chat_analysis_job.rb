class ChatAnalysisJob < ApplicationJob
  def perform(chat)
    Gpt.chat(prompt: Prompts.get("chats.analyze"), transcript: chat.messages_for_gpt).then do |json|
      JSON.parse(json, symbolize_names: true).then do |data|
        Rails.logger.info(data)
        chat.title = data[:title] if data[:title]
        chat.analysis = chat.analysis.merge(data)
        chat.save!
      end
    end
  end
end
