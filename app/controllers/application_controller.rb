class ApplicationController < ActionController::Base
  include CableReady::Broadcaster

  helper_method :current_user

  def current_user
    session[:user_id] && User.find_by(id: session[:user_id])
  end

  def require_user
    redirect_to root_path unless current_user
  end
end
