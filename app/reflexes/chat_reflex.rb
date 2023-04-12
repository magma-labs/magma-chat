# frozen_string_literal: true

class ChatReflex < StimulusReflex::Reflex
  attr_reader :chat
  attr_reader :value

  before_reflex do
    if id = element.dataset[:id].presence
      @chat = Chat.find(id)
    else
      @chat = Chat.create(title: element.value, engine: "gpt-3.5-turbo")
    end
    @value = element.value
  end

  def prompt
    slash_filter do
      chat.prompt(message: element.value)
    end
  end

  def destroy
    chat.destroy!
  end

  private

  def slash_filter
    if value.starts_with?("/")
      case value.strip
      when /^\/new/
        # assume the title is whatever string supplied after the /new command
        title = value.split("/new").last&.strip.presence || "New Chat"
        @chat = Chat.create(title: title, engine: "gpt-3.5-turbo")
        cable_ready.redirect_to(url: "/chats/#{chat.id}").broadcast
        morph :nothing
      when /^\/delete/
        @chat.destroy
        cable_ready.redirect_to(url: "/chats/new").broadcast
        morph :nothing
      when /^\/clear/
        # todo: implement
      when /^\/stats/
        # todo: implement
      when /^\/summarize/
        # todo: implement
      when /^\/help/
        # todo: implement
      end
    else
      yield
    end
  end

end
