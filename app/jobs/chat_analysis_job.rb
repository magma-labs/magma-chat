class ChatAnalysisJob < ApplicationJob
  queue_as :default

  def perform(chat)
    Gpt.chat(prompt: Prompts.get("chats.analyze"), transcript: chat.messages_for_gpt).then do |json|
      unless json.starts_with?("{") && json.end_with?("}")
        json = extract_json(json)
      end
      JSON.parse(json, symbolize_names: true).then do |data|
        Rails.logger.info(data)
        chat.title = data[:title] if data[:title]
        chat.analysis = chat.analysis.merge(data)
        chat.save!
      end
    end
  end

  private

  def extract_json(text)
    start_index = text.index('{')
    return nil if start_index.nil?

    end_index = start_index
    brace_count = 1

    text[start_index + 1..-1].each_char.with_index do |char, index|
      brace_count += 1 if char == '{'
      brace_count -= 1 if char == '}'
      end_index += 1
      break if brace_count.zero?
    end

    text[start_index..end_index]
  end

end
