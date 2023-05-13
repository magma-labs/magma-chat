class AnalysisJob < ApplicationJob
  queue_as :default

  attr_reader :conversation

  JSON_SCHEMA = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    type: "object",
    properties: {
      title: {
        type: "string",
        maxLength: 140,
        description: "An appropriate title."
      },
      summary: {
        type: "string",
        maxLength: 280,
        description: "One paragraph summary with brief overview highlights of significant points (if any)."
      },
      tags: {
        type: "array",
        items: {
          type: "string",
          description: "Array of lowercase tags representing main themes of the conversation."
        }
      },
      next: {
        type: "array",
        items: {
          type: "string",
          description: "Array of questions or comments that the user might say next to the assistant."
        }
      }
    },
    "required": ["title", "summary", "tags", "next"]
  }

  def perform(conversation)
    @conversation = conversation
    # todo: make idle time configurable
    if time_to_analyze?
      directive = Magma::Prompts.get("conversations.analysis_directive", json_schema: JSON_SCHEMA.to_json)
      Gpt.chat(
        directive: directive,
        prompt: formatted(conversation.messages_for_gpt(only_visible: true)),
        max_tokens: 300
      ).then do |json|

        Rails.logger.info("🔥🔥🔥 #{json} 🔥🔥🔥")

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

  def formatted(messages)
    messages.map do |message|
      "#{message[:role]}: #{message[:content]}"
    end.join("\n")
  end

  def time_to_analyze?
    return false if conversation.messages.last.content.blank?
    conversation.last_analysis_at ||= conversation.created_at
    Time.current - conversation.last_analysis_at > 1.minute
  end
end
