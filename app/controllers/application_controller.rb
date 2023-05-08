class ApplicationController < ActionController::Base
  include CableReady::Broadcaster

  around_action :set_time_zone, if: :current_user

  helper_method :current_admin?
  helper_method :current_user

  protected

  def current_admin?
    !!current_user&.admin?
  end

  def current_user
    @current_user ||= session[:user_id] && User.find_by(id: session[:user_id])
  end

  def load_latest_conversations
    @latest_conversations = current_user.conversations.order(updated_at: :desc).limit(10)
  end

  def require_user
    if current_user
      cookies.encrypted[:user_id] = current_user&.id
    else
      redirect_to root_path
    end
  end

  private

  def set_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
end
