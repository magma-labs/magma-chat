class ChatReindexJob < ApplicationJob
  queue_as :default

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
      Marqo.client.store(
        index: INDEX,
        doc: doc.merge(message),
        id: "#{chat.id}-#{index}",
        non_tensor_fields: [:chat_id, :user_id, :language, :sentiment, :tags]
      )
    end
  end
end
