class AdminConstraint
  def self.matches?(request)
    user_id = request.session[:user_id]

    if user_id.present?
      user = User.find_by(id: user_id)
      return user&.admin?
    end

    false
  end
end
