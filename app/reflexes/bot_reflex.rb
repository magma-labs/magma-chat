# frozen_string_literal: true

class BotReflex < ApplicationReflex
  attr_reader :bot
  before_reflex :load_bot

  def promote
    @bot.update_column(:type, "Agent")
    cable_ready.redirect_to(url: "/bots/#{@bot.id}").broadcast
    morph :nothing
  end

  def destroy
    if @bot.chats.empty?
      @bot.destroy!
      cable_ready.redirect_to(url: "/bots").broadcast
    end
    morph :nothing
  end


  private

  def load_bot
    if id = element.dataset[:id].presence
      @bot = Bot.find(id)
    end
  end
end
