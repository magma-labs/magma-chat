class ChatResponsibilityJob < ApplicationJob
  queue_as :default

  def perform(chat)
    prompt = Magma::Prompts.get("chats.responsibility.prompt", bot_role: chat.bot.role, bot_directive: chat.bot.directive)
    tokens_count = TikToken.count(chat.bot.directive + prompt)

    # gather
    Gpt.chat(
      directive: chat.bot.directive,
      prompt: prompt,
      transcript: chat.messages_for_gpt(tokens_count + 300, only_visible: true).take(6),
      max_tokens: 500,
    ).then do |response|
      if response.blank?
        Rails.logger.warn "😵😵😵 No response to responsibility for Chat: #{chat.id}"
      else
        response.scan(/\d+\. (.*?)\n/).flatten.each do |responsibility|
          chat.bot.responsibilities.create(subject: chat.user, brief: responsibility)
        end
      end
    end

    # condense
    prompt = Magma::Prompts.get("chats.responsibility.prompt_condense", responsibilities: current_responsibilities_of(chat.bot, chat.user))

    Gpt.chat(
      directive: chat.bot.directive,
      prompt: prompt,
    ).then do |response|
      if response.blank?
        Rails.logger.warn "😵😵😵 No response to responsibility condensation for Chat: #{chat.id}"
      else
        new_list = response.scan(/\d+\. (.*?)\n/).flatten
        if new_list.any?
          Responsibility.transaction do
            chat.bot.responsibilities.where(subject: chat.user).destroy_all
            new_list.each do |responsibility|
              chat.bot.responsibilities.create(subject: chat.user, brief: responsibility)
            end
          end
        end
      end
    end
  end

  private

  def current_responsibilities_of(bot, user)
    bot.responsibilities.where(subject: user).map(&:brief).each_with_index.map do |brief, index|
      "#{index+1}. #{brief}"
    end.join("\n")
  end
end
