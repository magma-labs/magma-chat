class BotsController < ApplicationController
  before_action :require_user
  before_action :load_latest_conversations
  before_action :set_bot, only: [:new_conversation, :show]

  def index
  end

  def show
    @conversations = @bot.conversations
    # can be set by reflex
    @thoughts ||= @bot.thoughts.latest
  end

  def new_conversation
    first_conversation = @bot.conversations.where(user: current_user).empty?
    first_message = first_conversation ? "Hello, please introduce yourself." : "Hello!"

    current_user.conversations.create!(bot: @bot, first_message: first_message).then do |conversation|
      redirect_to [conversation]
    end
  end

  private

  def set_bot
    @bot = Bot.find(params[:id])
  end
end
