class ApplicationController < ActionController::Base
  include CableReady::Broadcaster

  helper_method :current_user

  protected

  def current_user
    session[:user_id] && User.find_by(id: session[:user_id])
  end

  def require_user
    if current_user
      cookies.encrypted[:user_id] = current_user&.id
    else
      redirect_to root_path
    end
  end
end
