class Message::UserStrategy < Message::BaseStrategy
  def set_sender
    context.sender = chat.user
  end
end
