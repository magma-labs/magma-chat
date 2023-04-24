class MemoryAnnotator
  attr_reader :chat

  ## takes the last number of n messages, generates a list of questions about the conversation, and searches for matching thoughts
  ## if any matching thoughts are found in long term memory, they are added to the chat as hidden messages
  def initialize(chat)
    @chat = chat
  end

  def perform(number_of_messages_to_pop: 6)
    # no point if there's no Marqo service attached
    return if ENV['MARQO_URL'].blank?

    response = Gpt.chat(transcript: Prompts.get("conversation_analyzer.prelude"), prompt: prompt(number_of_messages_to_pop))
    extract_questions(response).map do |question|
      filter = "bot_id:#{chat.bot.id} AND subject_id:#{chat.user.id}"
      Marqo.client.search("thoughts", question, filter: filter, limit: 3)
    end.map do |search_result|
      # todo: consider relevance score and only add if above a certain threshold
      if search_result.hits.nil? || search_result.hits.empty?
        Rails.logger.debug("❌ MEMORY NOT FOUND #{search_result.query} ❌")
      else
        memory = compile_content(search_result.query, search_result.hits)
        Rails.logger.debug("💡 Creating Memory Message for #{memory} 💡")
        chat.user_message!(memory)
      end
    end
  end

  private

  def compile_content(query, hits)
    [
      "You asked your long-term memory: #{query}",
      "And you remembered the following:",
      hits.map { |h| h.brief }.join("\n\n")
    ].join("\n\n")
  end

  def extract_questions(text)
    text.scan(/^\d+\. (.*)$/).flatten
  end

  def prompt(number_of_messages_to_pop)
    Prompts.get(
      "conversation_analyzer.prompt",
      user_name: chat.user.name,
      bot_role: chat.bot.role,
      bot_name: chat.bot.name,
      t: transcript(number_of_messages_to_pop)
    )
  end

  def transcript(number_of_messages_to_pop)
    messages = Message.where(chat_id: chat.id).latest.visible.limit(number_of_messages_to_pop)
    conversation = messages.to_a.reverse.map do |m|
      [m.sender_name, m.content].join(": ")
    end.join("\n\n")
  end
end
