class ChatAnalysisJob < ApplicationJob
  queue_as :default

  def perform(chat)
    directive = Magma::Prompts.get("chats.analysis_directive")
    prompt = Magma::Prompts.get("chats.analyze", lang: chat.user.preferred_language)
    prompt_tokens = TikToken.count(prompt)
    Gpt.chat(
      directive: directive,
      prompt: prompt,
      max_tokens: 300,
      transcript: chat.messages_for_gpt(prompt_tokens + 200, only_visible: true)
    ).then do |json|
      puts
      puts "🔥🔥🔥 #{json} 🔥🔥🔥"
      puts
      # todo: error handling
      JSON.parse(json.match(/.*?(\{.*\})/m)[1], symbolize_names: true).then do |data|
        Rails.logger.info(data)
        chat.title = data[:title] if data[:title]
        chat.analysis = chat.analysis.merge(data)
        chat.save!
      end
    end
  end
end
