class ChatSearch
  attr_reader :results
  attr_reader :query

  def initialize(results, query)
    @results = results
    @query = query
  end

  # TODO: Scope searches to user's chats ONLY

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
    response = Marqo.client.lexsearch("chats", [:tags], query)
    response.deep_symbolize_keys!
    new(response.dig(:hits).group_by { |hit| hit[:chat_id] }.map { |chat_id, hits|
      chat_result = OpenStruct.new(chat: Chat.find(chat_id), messages: [])
    }, "tag: #{response[:query]}")
  end
end
