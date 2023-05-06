class ObservationJob < ApplicationJob
  queue_as :default

  attr_reader :conversation
  delegate :bot, :user, to: :conversation

  def perform(conversation)
    @conversation = conversation
    make_observations.then do |list|
      #rank_and_save!(list)
    end
  end

  private

  def entities
    [World.instance.things, user, bot].flatten
  end

  def make_observations
    directive = Magma::Prompts.get("conversations.observation.directive")
    prompt = Magma::Prompts.get(
      "conversations.observation.make.prompt",
      user_name: user.name, bot_name: bot.name, bot_role: bot.role
    )
    tokens_used = TikToken.count(directive + prompt)
    Gpt.chat(
      directive: directive,
      transcript: conversation.messages_for_gpt(tokens_used, only_visible: true),
      prompt: prompt,
      temperature: 0.6, # todo: make configurable
      max_tokens: 300 # todo: make configurable
    ).then do |response|
      # todo: error handling
      refine_and_save!(response)
    end
  end

  def refine_and_save!(observations)
    directive = Magma::Prompts.get("conversations.observation.refine.directive")
    prompt = Magma::Prompts.get(
      "conversations.observation.refine.prompt",
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
        bot.observations.create!(observations)
      end
    end
  end
end
