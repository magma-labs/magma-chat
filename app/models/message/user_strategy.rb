class Message::UserStrategy < Message::BaseStrategy
  def broadcast_message
    ChatPromptJob.perform_later(chat, content, visible)
  end

  def set_sender
    context.sender = chat.user
  end
end
