class BotsController < ApplicationController
  before_action :load_latest_conversations
  before_action :set_bot

  def show
    @conversations = @bot.conversations
    @thoughts = @bot.thoughts
  end

  private

  def set_bot
    @bot = Bot.find(params[:id])
  end
end
