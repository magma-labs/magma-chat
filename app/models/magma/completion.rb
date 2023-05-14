module Magma
  class Completion
    attr_accessor :model, :temperature, :top_p, :frequency_penalty, :presence_penalty, :max_tokens, :stream

    ##
    # Creates a new chat object for facilitating chat-style completions with OpenAI
    # Takes optional parameters:
    # - model: String. Defaults to `text-davinci-003`
    # - temperature: Float between 0 and 1. Defaults to 0.7
    # - top_p: Float between 0 and 1. Defaults to 1.0
    # - frequency_penalty: Float between 0 and 1. Defaults to 0.0
    # - presence_penalty: Float between 0 and 1. Defaults to 0.0
    # - max_tokens: Integer. Defaults to 500
    # - stream: Proc that will be called with each response from OpenAI
    def initialize(model: nil,temperature: 0.7, top_p: 1.0, frequency_penalty: 0.0, presence_penalty: 0.0, max_tokens: 500, stream: nil)
      self.model = model || "text-davinci-003"
      self.temperature ||= temperature
      self.top_p ||= top_p
      self.frequency_penalty ||= frequency_penalty
      self.presence_penalty ||= presence_penalty
      self.max_tokens ||= max_tokens
      self.stream ||= stream
    end


    ##
    # Prompts GPT for a completion
    #
    # Takes optional parameters:
    # - key: String. The key to look up in `config/prompts.yml`.
    # - content: String. The prompt to send to GPT. If provided, `key` will be ignored
    # - any other parameters will be passed to `Magma::Prompts.get` to be interpolated into the prompt
    #
    def prompt(key: nil, content: nil, **opts, &block)
      raise ArgumentError, "key or content must be provided" unless key || content
      prompt = content || Magma::Prompts.get(key, **opts)

      response = send(prompt)

      # stop if we didn't get a reply
      return if response.nil? || response.empty?

      # return the error message if there is one, otherwise the first response
      reply = response.dig("error", "message") || response.dig("choices", 0, "text")

      # stop if we didn't get a reply
      return if reply.nil? || reply.empty?

      yield(reply) if block_given?

      reply
    end

    private

    def send(prompt)
      send_params = params.merge(prompt: prompt)
      Rails.logger.info("😏 GPT REQUEST: #{send_params} #{object_id}")
      Gpt.client.completions(parameters: send_params).tap do |response|
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
