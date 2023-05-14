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

  def search_thoughts
    @thoughts = Thought.where(id: @bot.ask(element.value, subject_id: current_user.id).hits.map(&:_id))
  end

  def generate_backstory
    # give the user some feedback
    cable_ready.text_content(selector: "#bot_backstory", text: "Generating... please wait.").broadcast

    backstory = Gpt.magic(
      description: "Writes a comprehensive, multi-paragraph personal history aka backstory
                    backstory for a character with the provided name and role. If the role
                    is a professional title, include resume and job history information.".squish,
      signature: "generate_backstory(name, role)",
      args: [@bot.name, @bot.role],
      max_tokens: 100,
      temp: 0.25
    )
    @bot.update(backstory: backstory.gsub('"',''))
  end

  def destroy
    if @bot.conversations.empty?
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
