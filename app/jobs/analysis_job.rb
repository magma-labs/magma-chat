class AnalysisJob < ApplicationJob
  queue_as :default

  attr_reader :conversation

  def perform(conversation)
    @conversation = conversation
    # todo: make idle time configurable
    if time_to_analyze?
      directive = Magma::Prompts.get("conversations.analysis_directive")
      prompt = Magma::Prompts.get("conversations.analyze", lang: conversation.user.preferred_language)
      prompt_tokens = TikToken.count(prompt)
      Gpt.chat(
        directive: directive,
        prompt: prompt,
        max_tokens: 300,
        transcript: conversation.messages_for_gpt(only_visible: true)
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
      conversation.touch(:last_analysis_at)
    else
      # save resources by skipping analysis until conversation is idle
      AnalysisJob.set(wait_until: 1.minute.from_now).perform_later(conversation)
    end
  end

  private

  def time_to_analyze?
    return false if conversation.messages.last.content.blank?
    return true if conversation.last_analysis_at.nil?
    conversation.last_analysis_at > 1.minute.ago
  end
end
