class Message::BaseStrategy
  include Strategic::Strategy

  delegate :conversation, :content, :visible, to: :context
  delegate :bot, :user, to: :conversation

  def broadcast_message
  end

  def override_disclaimers
  end

  def to_partial_path
    "messages/message"
  end
end
