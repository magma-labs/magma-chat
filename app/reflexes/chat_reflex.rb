# frozen_string_literal: true

class ChatReflex < StimulusReflex::Reflex
  before_reflex do
    if id = element.dataset[:id].presence
      @chat = Chat.find(id)
    else
      @chat = Chat.create(title: element.value, engine: "gpt-3.5-turbo")
    end
  end

  def prompt
    @chat.prompt(message: element.value)
  end

  def destroy
    @chat.destroy!
  end
end
