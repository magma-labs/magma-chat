
class LoggedConstraint
  class << self
    def matches?(request)
      request.session.has_key?(:user_id)
    end
  end
end
