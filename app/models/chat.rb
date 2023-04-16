class Chat < ApplicationRecord
  attribute :first_message

  belongs_to :user

  after_commit :prompt!, on: :create
  after_commit :reindex, on: :update

  enable_cable_ready_updates on: [:update]

  def analysis
    super.deep_symbolize_keys
  end

  def prompt!(message: title, visible: true, sender: user)
    Rails.logger.info("PROMPT: #{message}")
    if visible
      if sender.kind_of? User
        sender = { id: sender.id, image_url: sender.image_url, name: sender.name }
      end
      # should update the transcript for the user with the prompt
      self.transcript += [{ role: "user", content: message, timestamp: Time.now.to_i, user: sender }]
      save!
    end

    # should update the transcript for the user with the reply
    # todo: move to after_commit to prevent race condition missing latest message
    ChatPromptJob.perform_later(self, message, visible)
  end

  def regenerate!
    # todo: delete the last response and prompt again with the same message
    transcript.pop # remove the last GPT response
    last_prompt = transcript.pop.deep_symbolize_keys # remove the last user prompt
    prompt!(message: last_prompt[:content], user: last_prompt[:user])
  end

  def reindex
    ChatReindexJob.perform_later(self)
  end

  def language
    analysis[:language]
  end

  def sentiment
    analysis[:sentiment]
  end

  def summary
    analysis[:summary]
  end

  def messages_for_gpt
    [{ role: "user", content: instructions.strip },
     { role: "assistant", content: "Okay! I will append a JSON object surrounded by ~~~ to my normal responses."} ] + transcript.map do |message|
      { role: message[:role], content: message[:content] }
     end
  end

  def analysis_next
    analysis[:next] || []
  end

  def tags
    analysis[:tags].presence || []
  end

  def transcript
    super.map(&:deep_symbolize_keys)
  end

  private

  def instructions
    <<-INSTRUCTIONS
    At the end of every reply, you must append a JSON object wrapped in ~~~ with
    the following keys containing an analysis of the conversation so far:

    `title`: an appropriate title
    `summary`: one paragraph summary
    `sentiment`: one word sentiment analysis
    `language`: primary human or programming language used
    `tags`: array of lowercase tags for categorizing the conversation
    `next`: array of possible followup questions from the user

    INSTRUCTIONS
  end
end
