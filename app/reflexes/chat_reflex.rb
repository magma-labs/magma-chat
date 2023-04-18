# frozen_string_literal: true

class ChatReflex < StimulusReflex::Reflex
  attr_reader :chat
  attr_reader :value

  before_reflex :load_chat

  delegate :current_user, to: :connection

  def prompt(message: value)
    slash_filter do
      chat.prompt!(message: message, sender: current_user)
      # todo: render chats/loading partial into .message #loading div
      # cable_ready.morph(children_only: true, selector: ".message#loading", html: render(partial: "chats/loading")).broadcast
    end
    morph :nothing
  end

  def suggested
    @value = element.dataset[:value]
    prompt
  end

  def toggle_grow(_, checked)
    chat.update!(grow: checked)
  end

  def destroy
    chat.destroy!
    cable_ready.redirect_to(url: "/chats/new").broadcast
    morph :nothing
  end

  private

  def load_chat
    if id = element.dataset[:id].presence
      @chat = Chat.find(id)
    else
      @chat = Chat.create(title: element.value, engine: "gpt-3.5-turbo")
    end
    @value = element.value
  end

  def slash_filter
    if value.starts_with?("/")
      case value.strip
      when /^\/new/
        # assume the title is whatever string supplied after the /new command
        title = value.split("/new").last&.strip.presence || "New Chat"
        @chat = current_user.chats.create!(title: title, engine: "gpt-3.5-turbo")
        cable_ready.redirect_to(url: "/chats/#{chat.id}").broadcast
        morph :nothing
      when /^\/delete/
        destroy
      when /^\/clear/
        chat.update!(transcript: [])
      when /^\/redo/
        message = value.split("/redo").last&.strip
        chat.redo!(message)
      when /^\/whisper/
        # message = value.split("/whisper").last&.strip.presence
        # chat.prompt!(message: message, visible: false)
        # todo: some mechanism to message the user with a transient pop up response or something
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
