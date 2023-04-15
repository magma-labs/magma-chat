class Chat < ApplicationRecord
  attribute :first_message
  belongs_to :user
  enable_cable_ready_updates on: [:update]
  after_commit :prompt, on: :create

  # todo: is there a way to send and persist inner voice chat messages with instructions for GPT?
  # for example: why haven't you sent the analysis yet

  def analysis
    super.deep_symbolize_keys
  end

  def prompt(message: title, visible: true)
    Rails.logger.info("PROMPT: #{message}")
    if visible
      # should update the transcript for the user with the prompt
      self.transcript += [{ role: "user", content: message }]
      save!
    end

    # should update the transcript for the user with the reply
    # todo: move to after_commit to prevent race condition missing latest message
    ChatPromptJob.perform_later(self, message, visible)
  end

  def regenerate!
    # todo: delete the last response and prompt again with the same message
    transcript.pop # remove the last response
    prompt_message = transcript.pop["content"] # remove the last prompt message
    prompt(message: prompt_message, visible: true)
  end

  def summary
    analysis[:summary]
  end

  def transcript_with_instructions
    [{role: "user", content: instructions.strip },
     {role: "assistant", content: "Okay! I will append a JSON object surrounded by ~~~ to my normal responses."}] + transcript
  end

  def analysis_next
    analysis[:next] || []
  end

  def tags
    analysis[:tags].presence || []
  end

  private

  def instructions
    <<-INSTRUCTIONS
    Before finishing your response, append a JSON object wrapped in ~~~ to the end
    containing the following keys:

    `title`: an appropriate title for the conversation so far
    `summary`: a paragraph summarizing the conversation so far (optional, when you have enough context)
    `sentiment`: a 1 word sentiment analysis of the conversation so far
    `language`: the human or programming language used in this conversation
    `tags`: an array of lowercase tags for categorizing the conversation
    `next`: an array of suggested potential next prompts from the user (optional, if it makes sense)

    INSTRUCTIONS
  end
end
