class ChatObservationJob < ApplicationJob
  queue_as :default

  def perform(chat)
    directive = Prompts.get("chats.observation.directive")
    prompt = Prompts.get(
      "chats.observation.prompt",
      user_name: chat.user.name,
      bot_name: chat.bot.name,
      bot_role: chat.bot.role
    )

    Gpt.chat(
      directive: directive,
      transcript: chat.messages_for_gpt(TikToken.count(directive + prompt), only_visible: true),
      prompt: prompt,
      temperature: 0.6,
      max_tokens: 300
    ).then do |response|
      chat.bot_observations!(response.scan(/^\d+\. (.*)$/).flatten)
    end
  end
end
