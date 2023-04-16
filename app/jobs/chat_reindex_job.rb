class ChatReindexJob < ApplicationJob
  INDEX = "chats"

  def perform(chat)
    doc = {
      chat_id: chat.id,
      title: chat.title,
      language: chat.language,
      sentiment: chat.sentiment,
      tags: chat.tags.join(" "),
      user_id: chat.user_id
    }
    chat.transcript.each_with_index do |entry, index|
      message = { content: entry[:content], role: entry[:role] }
      Marqo.client.store(INDEX, doc.merge(message), "#{chat.id}-#{index}")
    end
  end
end
