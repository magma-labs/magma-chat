# frozen_string_literal: true

class BotReflex < ApplicationReflex
  attr_reader :bot
  before_reflex :load_bot

  def add_tool
    @bot.tools.create(name: "New Tool")
  end

  def publish
    @bot.update(published_at: Time.now)
  end

  def unpublish
    @bot.update(published_at: nil)
  end

  def destroy
    if @bot.chats.empty?
      @bot.destroy!
      cable_ready.redirect_to(url: "/admin/bots").broadcast
    end
    morph :nothing
  end

  def toggle_setting(_, checked)
    @bot.settings[element.dataset[:field]] = checked
    @bot.save!
  end

  private

  def load_bot
    if id = element.dataset[:id].presence
      @bot = Bot.find(id)
    end
  end
end
