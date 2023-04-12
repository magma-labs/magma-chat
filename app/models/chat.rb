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
    # todo: move to after_commit to prevent race condition missing latest message
    ChatPromptJob.perform_later(self, message)
  end

  def transcript_with_instructions
    [{role: "user", content: instructions.strip },
     {role: "assistant", content: "Okay! Whenever it makes sense I will append a JSON object to my normal responses with the information requested."}] + transcript
  end

  def analysis_next
    analysis["next"] || []
  end

  def tags
    analysis["tags"]
  end

  private

  def instructions
    <<-INSTRUCTIONS
    Starting after the first few messages, respond normally but before stopping append
    a JSON object wrapped in ~~~ to the end of the message with the following keys:

    `category`: a 1-2 word category for the conversation so far
    `summary`: a 1-2 sentence summary of the conversation so far
    `sentiment`: a 1 word sentiment analysis of the conversation so far
    `importance`: integer from 1-100 representing your subjective evaluation of the importance of this topic
    `language`: human language being used in this conversation, unless the conversation is about software programming then tell me the programming language
    `tags`: an array of lowercase tags labeling the conversation for later retrieval
    `next`: an array of suggested potential next prompts from the user

    Don't repeat keys if their value hasn't changed.

    INSTRUCTIONS
  end
end
