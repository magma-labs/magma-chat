class MessageRememberJob < ApplicationJob
  queue_as :default

  def perform(message)
    return if !message.visible?
    return if message&.content.blank?
    return unless message.conversation.bot.enable_shared_messages?

    if message.destroyed?
      message.delete_vector
    else
      message.store_vector if worth_remembering?(message)
    end
  end

  private

  def worth_remembering?(message)
    # TODO: change magic model string to a constant
    Magma::Chat.new(model: "gpt-4").then do |chat|
      chat.add_message(role: :user, content: message.content)
      attrs = {
        sender_name: message.sender.name,
        conversation: message.conversation_label
      }

      chat.yes_no_answer(key: "worth_remembering_yes_no", **attrs).tap do |reply|
        puts "Worth remembering? #{attrs.inspect} => #{reply.inspect}"
      end
    end
  end

end
