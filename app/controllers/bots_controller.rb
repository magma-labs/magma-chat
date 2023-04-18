class BotsController < ApplicationController
  before_action :require_admin

  def index
    @bots = Bot.all
  end
end
