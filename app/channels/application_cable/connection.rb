module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # todo: this is a hack to get around https://github.com/rails/rails/issues/48195
      # once that is fixed should switch back to simpler solution with encrypted cookie for user_id
      # turn cookies into a hash and find a key that matches user_id using a regex
      key = cookies.to_h.find { |k, _v| k.match?(/user_id/) }&.first
      user_id = cookies[key]
      return reject_unauthorized_connection if user_id.nil?
      user = User.find_by(id: user_id)
      return reject_unauthorized_connection if user.nil?
      self.current_user = user
    end
  end
end
