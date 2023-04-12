class Chat < ApplicationRecord
  attribute :first_message
  enable_cable_ready_updates on: [:update]
  after_commit :prompt, on: :create

  def prompt(message: title)
    Rails.logger.info("PROMPT: #{message}")
    # should update the transcript for the user with the prompt
    self.transcript += [{ role: "user", content: message }]
    save!
    # should update the transcript for the user with the reply
    ChatPromptJob.perform_later(self, message)
  end
end
