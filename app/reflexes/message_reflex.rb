# frozen_string_literal: true

class MessageReflex < ApplicationReflex
  attr_reader :message

  before_reflex :load_message

  def destroy
    message.destroy!
    morph :nothing
  end

  private

  def load_message
    if id = element.dataset[:id].presence
      @message = Message.find(id)
    end
  end
end
