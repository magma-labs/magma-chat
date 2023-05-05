class ChatObservationJob < ApplicationJob
  queue_as :default

  attr_reader :chat

  def perform(chat)
    @chat = chat
    make_observations.then do |list|
      #rank_and_save!(list)
    end
  end

  private

  def entities
    [World.instance.things, chat.user, chat.bot].flatten
  end

  def make_observations
    directive = Magma::Prompts.get("chats.observation.directive")
    prompt = Magma::Prompts.get(
      "chats.observation.make.prompt",
      user_name: chat.user.name, bot_name: chat.bot.name, bot_role: chat.bot.role
    )
    tokens_used = TikToken.count(directive + prompt)
    Gpt.chat(
      directive: directive,
      transcript: chat.messages_for_gpt(tokens_used, only_visible: true),
      prompt: prompt,
      temperature: 0.6, # todo: make configurable
      max_tokens: 300 # todo: make configurable
    ).then do |response|
      # todo: error handling
      refine_and_save!(response)
    end
  end

  def refine_and_save!(observations)
    directive = Magma::Prompts.get("chats.observation.refine.directive")
    prompt = Magma::Prompts.get(
      "chats.observation.refine.prompt",
      known_subjects: entities.map(&:to_subject_name).join("\n"),
      observations: observations,
      schema: Observation::JSON_SCHEMA
    )
    Gpt.chat(
      directive: directive,
      prompt: prompt,
      temperature: 0.6, # todo: make configurable
      max_tokens: 1000 # todo: make configurable
    ).then do |response|
      JSON.parse(response).map do |observations|
        chat.bot.observations.create!(observations)
      end
    end
  end
end
