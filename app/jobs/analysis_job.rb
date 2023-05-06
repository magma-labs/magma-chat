class AnalysisJob < ApplicationJob
  queue_as :default

  def perform(conversation)
    directive = Magma::Prompts.get("conversations.analysis_directive")
    prompt = Magma::Prompts.get("conversations.analyze", lang: conversation.user.preferred_language)
    prompt_tokens = TikToken.count(prompt)
    Gpt.chat(
      directive: directive,
      prompt: prompt,
      max_tokens: 300,
      transcript: conversation.messages_for_gpt(prompt_tokens + 200, only_visible: true)
    ).then do |json|
      puts
      puts "🔥🔥🔥 #{json} 🔥🔥🔥"
      puts
      # todo: error handling
      JSON.parse(json.match(/.*?(\{.*\})/m)[1], symbolize_names: true).then do |data|
        Rails.logger.info(data)
        conversation.title = data[:title] if data[:title]
        conversation.analysis = conversation.analysis.merge(data)
        conversation.save!
      end
    end
  end
end
