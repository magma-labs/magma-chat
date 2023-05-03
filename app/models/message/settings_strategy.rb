class Message::SettingsStrategy < Message::BaseStrategy
  def set_sender
  end

  def to_partial_path
    "messages/settings"
  end
end
