class Message::AssistantStrategy < Message::ParticipantStrategy
  def message_timeout_job
    # todo: make configurable or dynamic
    MessageTimeoutJob.set(wait: 2.minutes).perform_later(context)
  end

  def override_disclaimers
    return unless content.present? && conversation.bot.humanize?
    # todo: can we make this work in user's language not just English?
    regex = Regexp.new(Magma::Prompts.get("disclaimers").join("|"))
    if match = content.match(regex)
      context.visible = false
      conversation.reprompt_with_human_override!(context)
    end
  end

  def set_sender
    context.sender = bot
  end

end
