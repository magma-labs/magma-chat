class ObservationJob < ApplicationJob
  queue_as :default

  attr_reader :conversation
  delegate :bot, :user, to: :conversation

  def perform(conversation)
    @conversation = conversation
    if time_to_observe?
      Rails.logger.info("\n\nObservationJob for #{conversation.id} 👁👁\n\n")
      make_observations!
      conversation.touch(:last_observations_at)
    else
      # defer to save resources
      ObservationJob.set(wait_until: 1.minute.from_now).perform_later(conversation)
    end
  end

  private

  def entities
    [World.instance.things, user, bot].flatten
  end

  def make_observations!
    directive = Magma::Prompts.get("conversations.observation.directive")
    prompt = Magma::Prompts.get(
      "conversations.observation.make.prompt",
      user_name: user.name, bot_name: bot.name, bot_role: bot.role
    )
    Magma::OpenAI.chat(
      directive: directive,
      transcript: conversation.messages_for_gpt(only_visible: true, since: :last_observations_at),
      prompt: prompt,
      temperature: 0.6, # todo: make configurable
      max_tokens: 300 # todo: make configurable
    ).then do |response|
      # todo: error handling
      refine_and_save!(response)
    end
  end

  def refine_and_save!(observations)
    directive = Magma::Prompts.get("conversations.observation.directive")
    prompt = Magma::Prompts.get(
      "conversations.observation.refine.prompt",
      known_subjects: entities.map(&:to_subject_name).join("\n"),
      observations: observations,
      schema: Observation::JSON_SCHEMA
    )
    Magma::OpenAI.chat(
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

  def time_to_observe?
    last_message = conversation.messages.last
    return false if last_message.content.blank?
    conversation.last_observations_at ||= conversation.created_at
    Time.current - conversation.last_observations_at > 1.minute
  end
end
