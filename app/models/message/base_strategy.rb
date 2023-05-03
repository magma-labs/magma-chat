class Message::BaseStrategy
  include Strategic::Strategy

  delegate :chat, to: :context

  def to_partial_path
    "messages/message"
  end
end
