Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
    {
      name: "google_oauth2",
      scope: "email,profile,https://www.googleapis.com/auth/calendar.readonly",
      access_type: 'offline',
      prompt: 'consent',
      image_aspect_ratio: "square",
      image_size: 50
    }
end
