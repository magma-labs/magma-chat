module Magma
  class Chat
    class Message
      def initialize(role:, content:)
        @role = role
        @content = content
      end

      def to_entry
        { role: @role.to_s, content: @content }
      end
    end

    attr_accessor :model, :temperature, :top_p, :frequency_penalty, :presence_penalty, :max_tokens, :stream, :debug

    ##
    # Creates a new chat object for facilitating chat-style completions with OpenAI
    # Takes optional parameters:
    # - model: String. Defaults to the value of the `OPENAI_DEFAULT_MODEL` environment variable or "gpt-3.5-turbo"
    # - directive: String. Defaults to the value of the "gpt.default_chat_directive" in `config/prompts.yml`
    # - temperature: Float between 0 and 1. Defaults to 0.7
    # - top_p: Float between 0 and 1. Defaults to 1.0
    # - frequency_penalty: Float between 0 and 1. Defaults to 0.0
    # - presence_penalty: Float between 0 and 1. Defaults to 0.0
    # - max_tokens: Integer. Defaults to 500
    # - stream: Proc that will be called with each response from OpenAI
    # - debug: Boolean. Defaults to false. Puts responses from OpenAI to the console
    def initialize(model: nil, directive: nil, temperature: 0.7, top_p: 1.0, frequency_penalty: 0.0, presence_penalty: 0.0, max_tokens: 500, stream: nil, debug: false)
      self.model = model || ENV['OPENAI_DEFAULT_MODEL'] || 'gpt-3.5-turbo'
      self.temperature ||= temperature
      self.top_p ||= top_p
      self.frequency_penalty ||= frequency_penalty
      self.presence_penalty ||= presence_penalty
      self.max_tokens ||= max_tokens
      self.stream ||= stream
      self.debug ||= debug

      directive ||= Magma::Prompts.get("gpt.default_chat_directive")
      @messages = [ Message.new(role: :system, content: directive).to_entry ]
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
      reply = response.dig("choices", 0, "message", "content")
      @messages << Message.new(role: :assistant, content: reply).to_entry
      yield(reply) if block_given?
      while auto_continue && response["choices"].last["finish_reason"].match?(/length/)
        sleep 1 # don't hit the API too hard because rate limits
        if block_given?
          continue(&block)
        else
          reply += continue.dig("choices", 0, "message", "content")
        end
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

    private

    def send
      Gpt.client.chat(parameters: params.merge(messages: @messages)).tap do |response|
        puts response.inspect if debug
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
