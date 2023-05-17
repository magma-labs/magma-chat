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

  # def load_latest_conversations
  #   @latest_conversations = current_user.conversations.order(updated_at: :desc).limit(10)
  # end

  def load_latest_conversations
    subquery = current_user.conversations
      .select('bot_id, MAX(updated_at) as max_updated_at')
      .group(:bot_id)
      .to_sql

    @latest_conversations = Conversation
      .select('conversations.*')
      .from("(#{subquery}) AS subquery")
      .joins('INNER JOIN conversations ON conversations.bot_id = subquery.bot_id AND conversations.updated_at = subquery.max_updated_at')
      .includes(:bot)
      .includes(:latest_message)
      .order('conversations.updated_at DESC').to_a

    missing_bots = Bot.where.not(id: @latest_conversations.map(&:bot_id))
    missing_bots.each do |bot|
      @latest_conversations << Conversation.new(bot: bot)
    end

  end


  def require_user
    if current_user
      cookies[:user_id] = current_user.id
    else
      redirect_to root_path
    end
  end

  private

  def set_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
end
