class Message::UserStrategy < Message::ParticipantStrategy
  def broadcast_message
    ConversationJob.perform_later(conversation, content, visible)
  end

  def set_sender
    context.sender = user
  end
end
