class Message::BaseStrategy
  include Strategic::Strategy

  delegate :chat, to: :context
end
