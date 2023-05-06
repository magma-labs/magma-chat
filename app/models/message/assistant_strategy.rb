class Message::AssistantStrategy < Message::BaseStrategy
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
