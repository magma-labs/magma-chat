module Magma
  class Edit
    MODEL = "text-davinci-edit-001"

    attr_accessor :model, :input, :temperature, :top_p, :frequency_penalty, :presence_penalty, :max_tokens, :stream, :debug

    def initialize(model: nil, input: nil, temperature: 1, top_p: 1, debug: false)
      self.model = MODEL
      self.input = input
      self.temperature ||= temperature
      self.top_p ||= top_p
      self.debug ||= debug
    end

    def process(instruction)
      @instruction = instruction
      self.input = send
    end

    private

    def send
      Magma::OpenAI.client.edits(parameters: params).tap do |response|
        puts response.inspect if debug
      end.then do |response|
        response.dig("choices", 0, "text")
      end
    end

    def params
      {
        model: model,
        input: input,
        instruction: @instruction,
        temperature: temperature,
        top_p: top_p,
      }
    end
  end
end
