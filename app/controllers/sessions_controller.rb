class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(auth_hash)
    session[:user_id] = user.id

    # Fetch the user's primary calendar timezone
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = google_oauth2_credentials

    # todo: should we do this everytime?
    calendar = service.get_calendar('primary')
    user.update!(time_zone: calendar.time_zone)

    redirect_to "/conversations", notice: "Signed in!"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

  private

  def google_oauth2_credentials
    Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      refresh_token: auth_hash[:credentials][:refresh_token],
      access_token: auth_hash[:credentials][:token],
      expires_at: auth_hash[:credentials][:expires_at],
      scope: 'https://www.googleapis.com/auth/calendar.readonly'
    )
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
