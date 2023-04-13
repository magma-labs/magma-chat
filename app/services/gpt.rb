require 'openai'

module Gpt
  extend self

  DIRECTIVE = "You are a smart and succinct assistant."

  def client
    @client ||= OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
  end

  def chat(directive: DIRECTIVE, prompt:, transcript: [], temperature: 0.7, frequency_penalty: 0.0, presence_penalty: 0.0, max_tokens: 1000, cache: 10.seconds)
    Rails.cache.fetch(key([directive, prompt, transcript, temperature, frequency_penalty, presence_penalty, max_tokens]), expires_in: cache) do
      messages = [{ role: "system", "content": directive}]
      messages += transcript
      messages += [{ role: "user", content: prompt}]
      params = { model: "gpt-3.5-turbo", messages: messages, temperature: temperature, frequency_penalty: frequency_penalty, presence_penalty: presence_penalty, max_tokens: max_tokens }

      Rails.logger.info("GPT REQUEST: #{params}")

      client.chat(parameters: params).then do |response|
        Rails.logger.info("GPT RESPONSE: #{response}")
        return response.dig("choices", 0, "message","content")
      end
    end
  end


  private


  def key(params)
    "gpt:#{Digest::SHA256.hexdigest(params.join)}"
  end
end
