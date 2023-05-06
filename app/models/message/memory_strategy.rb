class Message::MemoryStrategy < Message::BaseStrategy
  def set_sender
    context.sender = user
  end
end
