class Message::AssistantStrategy < Message::ParticipantStrategy
  def message_timeout_job
    # todo: make configurable or dynamic
    MessageTimeoutJob.set(wait: 2.minutes).perform_later(context)
  end

  def override_disclaimers
    if content.present? && conversation.bot.humanize?
      # todo: can we make this work in user's language not just English?
      regex = Regexp.new(Magma::Prompts.get("disclaimers").join("|"))

      if content.match(regex)
        Rails.logger.info("🙃🙃 Found a disclaimer in #{content} ")
        # make the message go away
        context.content = ""
        context.visible = false
        context.marked_for_deletion = true

        # this is a fast operation so just do it synchronously
        Magma::Completion.new(temperature: 1.2).then do |completion|
          reply = completion.prompt(key: "conversations.reprompt_with_human_override",
            backstory: bot.backstory,
            bot_name: bot.name,
            bot_role: bot.role,
            user_name: user.name,
            user_message: context.responding_to
          )
          # the gsub is in there because sometimes GPT adds quotes around the reply
          conversation.bot_message!(reply.gsub(/\A"|"\Z/, ''), visible: true)
        end
      end
    end
  end

  def set_sender
    context.sender = bot
  end

end
