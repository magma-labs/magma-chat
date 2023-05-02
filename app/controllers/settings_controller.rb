class SettingsController < ApplicationController
  before_action :require_user
  before_action :load_latest_chats

  def update
    current_user.update!(settings_params.to_h)
    redirect_to settings_path, notice: "Settings updated"
  end

  private

  def settings_params
    params.require(:user).permit(t("settings").keys)
  end
end
