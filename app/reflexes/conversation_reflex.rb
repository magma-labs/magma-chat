# frozen_string_literal: true

class ConversationReflex < ApplicationReflex
  attr_reader :conversation
  attr_reader :value

  before_reflex :load_conversation

  delegate :bot, :user, to: :conversation

  def prompt(message: value)
    puts "prompting with #{message}"
    slash_filter do
      conversation.prompt!(message: message, sender: current_user)
    end
    morph :nothing
  end

  def suggested
    @value = element.dataset[:value]
    prompt
  end

  def toggle_grow(_, checked)
    conversation.update!(grow: checked)
  end

  def destroy
    conversation.destroy!
    cable_ready.redirect_to(url: "/conversations/new").broadcast
    morph :nothing
  end

  private

  def load_conversation
    # todo: probably should be scoped to current_user
    if id = element.dataset[:id].presence
      @conversation = Conversation.find(id)
    else
      @conversation = Conversation.create(title: element.value)
    end
    @value = element.value
  end

  def slash_filter
    if value.starts_with?("/")
      case value.strip
      when /^\/new/
        # assume the title is whatever string supplied after the /new command
        msg = value.split("/new").last&.strip.presence || "Hello"
        @conversation = current_user.conversations.create!(bot: bot, first_message: msg)
        reload
      when /^\/delete/
        destroy
      when /^\/clear/
        conversation.messages.destroy_all
      when /^\/grow/
        conversation.toggle!(:grow)
        reload
      when /^\/redo/
        if conversation.messages.any?
          message = value.split("/redo").last&.strip
          conversation.redo!(current_user, message)
        end
      when /^\/public/
        if conversation.messages.any?
          conversation.update!(public_access: true)
          reload
        end
      when /^\/private/
        conversation.update!(public_access: false)
        reload
      when /^\/settings/
        conversation.display_settings!
      when /^\/stream/
        current_user.update!(streaming: !current_user.streaming)
        reload
      when /^\/whisper/
        # message = value.split("/whisper").last&.strip.presence
        # conversation.prompt!(message: message, visible: false)
        # todo: some mechanism to message the user with a transient pop up response or something
      when /^\/stats/
        # todo: implement
      when /^\/summarize/
        # todo: implement
      when /^\/help/
        # todo: implement
      when /^\/debug/
        conversation.update!(show_invisibles: !conversation.show_invisibles)
        reload
      end
    else
      yield
    end
  end

  def reload
    cable_ready.redirect_to(url: "/conversations/#{conversation.id}").broadcast
    morph :nothing
  end

end
