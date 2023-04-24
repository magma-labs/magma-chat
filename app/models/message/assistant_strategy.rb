class Message::AssistantStrategy < Message::BaseStrategy
  def set_sender
    context.sender = chat.bot
  end
end
