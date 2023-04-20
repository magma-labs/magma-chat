# frozen_string_literal: true

class ApplicationReflex < StimulusReflex::Reflex
  delegate :current_user, to: :connection
  delegate :helpers, to: :ApplicationController
end
