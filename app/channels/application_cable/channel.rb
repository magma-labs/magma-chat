module ApplicationCable
  class Channel < ActionCable::Channel::Base
    include CableReady::Broadcaster
  end
end
