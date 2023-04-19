class ApiController < ApplicationController
  # skip CSRF token verification
  skip_before_action :verify_authenticity_token

  def index
    Rails.logger.info("API: #{params}")
    # return plain text hello world
    render plain: "Got it! #{params}"
  end
end
