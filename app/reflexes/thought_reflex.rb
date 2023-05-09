# frozen_string_literal: true

class ThoughtReflex < ApplicationReflex
  attr_reader :thought
  before_reflex :load_thought

  def edit
  end

  def share
  end

  def destroy
    @thought.destroy!
    morph :nothing
  end


  private

  def load_thought
    if id = element.dataset[:id].presence
      @thought = Bot.find(id)
    end
  end
end
