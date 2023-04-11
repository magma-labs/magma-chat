class ApplicationController < ActionController::Base
  include CableReady::Broadcaster
end
