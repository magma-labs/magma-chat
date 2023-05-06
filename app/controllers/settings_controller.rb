class SettingsController < ApplicationController
  before_action :require_user
  before_action :load_latest_conversations

  def update
    current_user.update!(settings_params)
    redirect_to settings_path, notice: "Settings updated"
  end

  private

  def settings_params
    params.require(:user).permit(t("settings").keys).to_h
  end
end
