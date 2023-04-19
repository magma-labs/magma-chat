class ChatSearch
  attr_reader :results
  attr_reader :query

  def initialize(results, query)
    @results = results
    @query = query
  end

  # TODO: Scope searches to user's chats ONLY

  def self.message_content(query)
    new(Message.search_content(query).group_by(&:chat_id).map { |chat_id, messages|
      chat_result = OpenStruct.new(
        chat: Chat.find(chat_id),
        messages: messages
      )
    }, query)
  end

  def self.tensor(query)
    response = Marqo.client.search("chats", query)
    response.deep_symbolize_keys!
    new(response.dig(:hits).group_by { |hit| hit[:chat_id] }.map { |chat_id, hits|
      chat_result = OpenStruct.new(
        chat: Chat.find(chat_id),
        messages: hits.sort_by { |hit| hit[:_id] }.map do |hit|
          OpenStruct.new(id: hit[:_id], content: hit[:content], role: hit[:role])
        end
      )
    }, response[:query])
  end

  def self.tag(query)
    new(Chat.search_tags(query).map { |chat|
      OpenStruct.new(chat: chat, messages: [])
    }, "tag: #{query}")
  end
end
