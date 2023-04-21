class SettingsController < ApplicationController
  before_action :require_user
  before_action :load_latest_chats

  def show
  end

  def update
    current_user.update!(settings: settings_params)
    cache_language
    redirect_to settings_path, notice: "Settings updated"
  end

  private

  def cache_language
    languages = Rails.cache.fetch(:languages) { Set.new }
    unless languages.include?(current_user.settings.preferred_language)
      languages << current_user.settings.preferred_language
      Rails.cache.write(:languages, languages)
    end
  end


  def settings_params
    params.require(:user).permit(current_user.settings.to_h.keys)
  end
end
