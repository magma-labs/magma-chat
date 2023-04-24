class Message::MemoryStrategy < Message::BaseStrategy
  def set_sender
    context.sender = chat.user
  end
end
