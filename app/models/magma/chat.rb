module Magma
  class Chat
    class Message
      def initialize(role:, content:)
        @role = role
        @content = content
      end

      def to_entry
        return nil if @content.blank?
        { role: @role.to_s, content: @content }
      end
    end

    attr_accessor :model, :temperature, :top_p, :frequency_penalty, :presence_penalty, :max_tokens, :stream

    ##
    # Creates a new chat object for facilitating chat-style completions with OpenAI
    # Takes optional parameters:
    # - model: String. Defaults to the value of the `OPENAI_DEFAULT_MODEL` environment variable or "gpt-3.5-turbo"
    # - directive: String. Defaults to the value of the "gpt.default_chat_directive" in `config/prompts.yml`
    # - transcript: Array of existing entries to include as context. Defaults to []
    # - temperature: Float between 0 and 1. Defaults to 0.7
    # - top_p: Float between 0 and 1. Defaults to 1.0
    # - frequency_penalty: Float between 0 and 1. Defaults to 0.0
    # - presence_penalty: Float between 0 and 1. Defaults to 0.0
    # - max_tokens: Integer. Defaults to 500
    # - stream: Proc that will be called with each response from OpenAI
    def initialize(model: nil, directive: nil, transcript: [], temperature: 0.7, top_p: 1.0, frequency_penalty: 0.0, presence_penalty: 0.0, max_tokens: 500, stream: nil)
      self.model = model || ENV['OPENAI_DEFAULT_MODEL'] || 'gpt-3.5-turbo'
      self.temperature ||= temperature
      self.top_p ||= top_p
      self.frequency_penalty ||= frequency_penalty
      self.presence_penalty ||= presence_penalty
      self.max_tokens ||= max_tokens
      self.stream ||= stream

      directive ||= Magma::Prompts.get("gpt.default_chat_directive")
      @messages = [ Message.new(role: :system, content: directive).to_entry ]
      @messages += transcript # prevent blank messages
    end

    ##
    # Adds a message to the transcript.
    def add_message(role:, content:)
      @messages << Message.new(role: role, content: content).to_entry
    end

    ##
    # Prompts GPT for a chat reply.
    #
    # Takes optional parameters:
    # - key: String. The key to look up in `config/prompts.yml`.
    # - auto_continue: Boolean. If true, will continue the conversation until GPT stops responding (default: false)
    # - content: String. The prompt to send to GPT. If provided, `key` will be ignored
    # - any other parameters will be passed to `Magma::Prompts.get` to be interpolated into the prompt
    # - if a block is given, it will be passed the response hash from OpenAI, possibly multiple times
    # - if no block is given, optionally auto_continue the conversation until GPT stops responding and return the full content
    #
    # Example:
    #   ```
    #   chat = Magma::Chat.new(max_length: 20)
    #   chat.prompt(key: "most.famous.movie.featuring.character.named", name: "Bob", auto_continue: true) do |reply|
    #     puts reply
    #   end
    #   # => "One of the most famous movies featuring a character named Bob is "Fight Club" (1999),
    #         directed by David Fincher and starring Brad Pitt and Edward Norton. Brad Pitt's character,
    #         Tyler Durden, often addresses Edward Norton's character as "Bob" throughout the movie.
    #         Bob is a member of the fight club and is played by actor Meat Loaf. The film has become
    #         a cult classic and is known for its unconventional storytelling, themes of consumerism
    #         and masculinity, and its twist ending.
    #  ```
    #
    # Auto continue leverages the fact that GPT will return a "finish_reason" of "length" when it feels that it
    # was cut off mid-sentence. This is not a perfect solution, but it works well enough for now.
    # See https://beta.openai.com/docs/api-reference/completions/create for more information.
    def prompt(key: nil, auto_continue: false, content: nil, **opts, &block)
      raise ArgumentError, "key or content must be provided" unless key || content
      content = content || Magma::Prompts.get(key, **opts)
      @messages << Message.new(role: :user, content: content).to_entry
      response = send
      # stop if we didn't get a reply
      return if response.nil? || response.empty?

      # return the error message if there is one, otherwise the first response
      reply = response.dig("error", "message") || response.dig("choices", 0, "message", "content")

      # stop if we didn't get a reply
      return if reply.nil? || reply.empty?

      reply = reply.force_encoding("UTF-8") # todo: is this enough?
      @messages << Message.new(role: :assistant, content: reply).to_entry
      yield(reply) if block_given?
      # todo: in testing, sometimes we don't get a stop reason which causes a runaway loop
      while auto_continue && response["choices"].last["finish_reason"].match?(/length/)
        sleep 1 # don't hit the API too hard because rate limits
        if block_given?
          continue(&block)
        else
          reply += continue.dig("choices", 0, "message", "content")
        end
        # todo: make max continues configurable
      end
      reply
    end

    ##
    # Convenience method for prompting GPT to continue the conversation.
    # If a block is given, it will be passed the response hash from OpenAI.
    # Otherwise, returns the response hash
    def continue(&block)
      # todo: add check parameter which asks model if there's more to say
      if block_given?
        prompt(key: "gpt.continue_prompt", &block)
      else
        prompt(key: "gpt.continue_prompt")
      end
    end

    ##
    # Convenience method for asking GPT a simple yes no question.
    # returns boolean `true` if yes, `false` if no
    def yes_no_answer(key: nil, content: nil, **opts)
      prompt(key: key, content: content, **opts).then do |reply|
        !!reply.match?(/yes/i)
      end
    end

    private

    def send
      send_params = params.merge(messages: @messages.compact)
      Rails.logger.info("😏 GPT REQUEST: #{send_params} #{object_id}")
      Gpt.client.chat(parameters: send_params).tap do |response|
        Rails.logger.info("👹 GPT RESPONSE: #{response} #{object_id}")
      end
    end

    def params
      {
        model: model,
        temperature: temperature,
        top_p: top_p,
        frequency_penalty: frequency_penalty,
        presence_penalty: presence_penalty,
        max_tokens: max_tokens,
        stream: stream
      }
    end
  end
end
