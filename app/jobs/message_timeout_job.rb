class MessageTimeoutJob < ApplicationJob
  queue_as :low_priority_queue

  def perform(message)
    # todo: use cable ready to send a notification to the user
    # telling them that the bot timed out waiting for API response
    message.destroy! if message.content.blank?
  end

end
