class Message::BaseStrategy
  include Strategic::Strategy

  delegate :chat, :content, :visible, to: :context

  def broadcast_message
  end

  def override_disclaimers
  end

  def to_partial_path
    "messages/message"
  end
end
