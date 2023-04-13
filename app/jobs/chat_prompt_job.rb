class ChatPromptJob < ApplicationJob
  def perform(chat, message, visible)
    Gpt.chat(prompt: message, transcript: chat.transcript_with_instructions).then do |reply|
      reply = extract_analysis(chat, reply.strip)
      if visible
        chat.transcript += [{ role: "assistant", content: reply }]
      end
      chat.save!
    end
    # todo: error handling
  end

  private

  def extract_analysis(chat, message)
    if message["~~~"]
      # extract string inside ~~~ tokens
      json = message.split("~~~").second
      JSON.parse(json, symbolize_names: true).then do |data|
        Rails.logger.info(data)
        chat.title = data[:title] if data[:title]
        chat.analysis = chat.analysis.merge(data)
      end
      message.gsub!(json, "")
      message.gsub!("~~~", "")
    else
      message
    end
  end
end
