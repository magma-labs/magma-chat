class Chat < ApplicationRecord
  attribute :first_message
  attribute :run_analysis_after_saving, :boolean, default: false

  belongs_to :user
  belongs_to :bot, optional: true, counter_cache: true

  before_create :set_title

  after_commit :prompt!, on: :create, if: :first_message
  after_commit :reanalyze, on: :update, if: :run_analysis_after_saving
  after_commit :reindex, on: :update

  enable_cable_ready_updates on: [:update]

  def analysis
    super.deep_symbolize_keys
  end

  def bot
    super || Bot.default
  end

  def bot_id
    super || Bot.default.id
  end

  def directive
    bot.directive
  end

  def prompt!(message: first_message, visible: true, sender: user)
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

  def reanalyze
    ChatAnalysisJob.perform_later(self)
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
    transcript.map do |message|
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

  def set_title
    if first_message.blank?
      self.title = "Conversation with #{bot.name}"
    else
      self.title = first_message
    end
  end

end
