class ChatSearch
  attr_reader :results
  attr_reader :query

  def initialize(results, query)
    @results = results
    @query = query
  end

  def self.message_content(current_user, query)
    search = Message.search_content(query)

    unless current_user.admin?
      search = search.joins(:chat).where(chat: { user_id: current_user.id })
    end

    results = search.group_by(&:chat_id).map do |chat_id, messages|
      OpenStruct.new(
        chat: Chat.find(chat_id),
        messages: messages,
        to_partial_path: "chats/result"
      )
    end

    new(results, query)
  end

  def self.tag(query)
    tags = Chat.search_tags(query).map do |chat|
      OpenStruct.new(chat: chat, messages: [], to_partial_path: "chats/result")
    end

    new(tags, "tag: #{query}")
  end
end
