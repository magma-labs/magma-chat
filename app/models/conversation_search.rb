class ConversationSearch
  attr_reader :results
  attr_reader :query

  def initialize(results, query)
    @results = results
    @query = query
  end

  def self.message_content(current_user, query)
    search = Message.search_content(query)

    unless current_user.admin?
      search = search.joins(:conversation).where(conversations: { user_id: current_user.id })
    end

    results = search.group_by(&:conversation_id).map do |conversation_id, messages|
      OpenStruct.new(
        conversation: Conversation.find(conversation_id),
        messages: messages,
        to_partial_path: "conversations/result"
      )
    end

    new(results, query)
  end

  def self.tag(query)
    tags = Conversation.search_tags(query).map do |conversation|
      OpenStruct.new(conversation: conversation, messages: [], to_partial_path: "conversations/result")
    end

    new(tags, "tag: #{query}")
  end
end
