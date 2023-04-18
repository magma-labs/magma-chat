class AdminController < ApplicationController
  before_action :require_user
  before_action -> { redirect_to root_path unless current_user.admin? }
end
