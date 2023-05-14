##
## A basic implementation of retrieval-augmented generation (or "RETRO")
## a) retrieves relevant data from outside of the language model (non-parametric) and
## b) augments the data with context in the prompt to the LLM. The architecture
## cleanly routes around most of the limitations of fine-tuning and context-only
## approaches. Read more at https://mattboegner.com/knowledge-retrieval-architecture-for-llms/
##
class MemoryAnnotator
  attr_reader :conversation
  attr_reader :memories_message

  delegate :bot, :user, to: :conversation

  class Memory
    attr_reader :question, :answer

    def initialize(question, answer)
      @question = question
      @answer = answer
    end
  end

  ## takes the last number of n messages, generates a list of questions about the conversation, and searches for matching thoughts
  ## if any matching thoughts are found in long term memory, they are added to the conversation as hidden messages
  def initialize(conversation, memories_message=nil)
    @conversation = conversation
    @memories_message = memories_message || conversation.user_message!("", visible: false)
    self
  end

  def perform(number_of_messages_to_pop: 6)
    # no point if there's no Marqo service attached
    return if ENV['MARQO_URL'].blank?

    unique_hits = Set.new

    response = Magma::OpenAI.chat(transcript: Magma::Prompts.get("conversation_analyzer.prelude"), prompt: prompt(number_of_messages_to_pop))
    questions = extract_questions(response)
    memories = questions.map do |question|
      search_result = bot.ask(question, subject_id: user.id)
      next if search_result.hits.nil? || search_result.hits.empty?

      Memory.new(question, search_result.hits.map(&:brief).to_sentence)
    end.compact

    # todo: consider relevance score and only add if above a certain threshold\
    memories_message.update!(content: compile_content(memories), visible: false)
  end

  private

  def compile_content(memories)
    memories.map do |memory|
      [
        "Q: #{memory.question}",
        "A: #{memory.answer}"
      ].join("\n")
    end.join("\n").then do |content|
      # wrap in brackets so that bot knows this is coming from MagmaChat system
      "[BOT MEMORY: #{content}]"
    end
  end

  def extract_questions(text)
    text.scan(/^\d+\. (.*)$/).flatten
  end

  def prompt(number_of_messages_to_pop)
    Magma::Prompts.get(
      "conversation_analyzer.prompt",
      user_name: user.name,
      bot_role: bot.role,
      bot_name: bot.name,
      t: transcript(number_of_messages_to_pop)
    )
  end

  def transcript(number_of_messages_to_pop)
    messages = Message.where(conversation_id: conversation.id).latest.visible.limit(number_of_messages_to_pop)
    conversation = messages.to_a.reverse.map do |m|
      [m.sender_name, m.content].join(": ")
    end.join("\n\n")
  end
end
