##
## A basic implementation of retrieval-augmented generation (or "RETRO")
## a) retrieves relevant data from outside of the language model (non-parametric) and
## b) augments the data with context in the prompt to the LLM. The architecture
## cleanly routes around most of the limitations of fine-tuning and context-only
## approaches. Read more at https://mattboegner.com/knowledge-retrieval-architecture-for-llms/
##
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

    unique_hits = Set.new

    response = Gpt.chat(transcript: Prompts.get("conversation_analyzer.prelude"), prompt: prompt(number_of_messages_to_pop))
    questions = extract_questions(response)
    questions.each do |question|
      filter = "bot_id:#{chat.bot.id} AND subject_id:#{chat.user.id}"
      search_result = Marqo.client.search("thoughts", question, filter: filter, limit: 3)
      next if search_result.hits.nil? || search_result.hits.empty?

      search_result.hits.each { |hit| unique_hits << hit.brief.strip }
    end

    # todo: consider relevance score and only add if above a certain threshold\
    chat.user_message!(compile_content(questions, unique_hits))
  end

  private

  def compile_content(questions, answers)
    [
      "You asked your long-term memory: \n\n #{questions.join("\n")}",
      "And you remembered the following: \n\n #{answers.join("\n")}"
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
