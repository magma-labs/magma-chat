class DashboardController < ApplicationController
  before_action :require_user
  before_action :load_latest_conversations

  def index
  end
end
