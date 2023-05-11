class BotsController < ApplicationController
  before_action :require_user
  before_action :load_latest_conversations
  before_action :set_bot, only: [:show]

  def index
  end

  def show
    @conversations = @bot.conversations
    # can be set by reflex
    @thoughts ||= @bot.thoughts.latest
  end

  private

  def set_bot
    @bot = Bot.find(params[:id])
  end
end
