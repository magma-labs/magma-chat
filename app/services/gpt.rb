require 'openai'

module Gpt
  extend self

  def client
    @client ||= OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
  end

  def chat(model: "gpt-3.5-turbo", directive: Prompts.get("gpt.chat_directive"), prompt:, transcript: [], temperature: 0.7, top_p: 1.0, frequency_penalty: 0.0, presence_penalty: 0.0, max_tokens: 500, cache: 10.seconds, stream: nil)
    Rails.cache.fetch(key([directive, prompt, transcript, temperature, frequency_penalty, presence_penalty, max_tokens]), expires_in: cache) do
      messages = [ message(:system, directive) ]
      messages += transcript
      messages += [ message(:user, prompt) ]
      params = {
        model: model,
        messages: messages,
        temperature: temperature,
        top_p: top_p,
        frequency_penalty: frequency_penalty,
        presence_penalty: presence_penalty,
        max_tokens: max_tokens,
        stream: stream
      }
      Rails.logger.info("GPT REQUEST: #{params}")
      client.chat(parameters: params).then do |response|
        Rails.logger.info("GPT RESPONSE: #{response}")
        if response.any?
          response.dig("error","message") || response.dig("choices", 0, "message", "content")
        end
      end
    end
  end

  ## The `magic` method takes the following parameters:
  ## `signature`: The method signature including name and parameters.
  ## `description`: Describes what the function does and what it returns.
  ## `args`: A list of arguments for the function.
  ## `model`: (Optional) A string specifying the GPT model to use.
  ## `temp`: (Optional) The temperature to use. Defaults to 1.0.
  ## `max_tokens`: (Optional) The maximum number of tokens to return. Defaults to 100.
  def magic(signature:, description:, args:, model: "gpt-3.5-turbo", temp: 1.0, max_tokens: 100)
    Rails.cache.fetch(key([signature, description, args, model, temp, max_tokens]), expires_in: 10.days) do
      messages = [
        message(:user, Prompts.get("gpt.magic_prompt", { signature: signature, description: description })),
        message(:assistant, "Understood. Waiting for arguments")
      ]
      chat(directive: Prompts.get("gpt.magic_directive"), prompt: args.join(", "), temperature: temp, transcript: messages)
    end
  end

  private

  def key(params)
    "gpt:#{Digest::SHA256.hexdigest(params.join)}"
  end

  def message(role, content)
    { role: role.to_s, content: content }
  end
end
