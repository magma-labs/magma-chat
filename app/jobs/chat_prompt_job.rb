class ChatPromptJob < ApplicationJob
  def perform(chat, message)
    Gpt.chat(prompt: message, transcript: chat.transcript_with_instructions).then do |reply|
      extract_analysis(chat, reply)
      chat.transcript += [{ role: "assistant", content: reply }]
      chat.save!
    end
    # todo: error handling
  end

  private

  def extract_analysis(chat, message)
    message.strip!
    if message["~~~"]
      # extract string inside ~~~ tokens
      json = message.match(/~~~(.*)~~~/m)[1]
      json ||= message.match(/~~~(.*)$/m)[1]
      JSON.parse(json, symbolize_names: true).then do |data|
        Rails.logger.info(data)
        chat.analysis = chat.analysis.merge(data)
      end
      message.gsub!(json, "")
      message.gsub!("~~~", "")
    end
  end
end
