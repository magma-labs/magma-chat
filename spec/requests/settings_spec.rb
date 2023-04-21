require 'rails_helper'

RSpec.describe "Settings", type: :request do
  before { login_user(create(:user)) }

  describe "GET /show" do
    xit "returns http success" do
      get "/settings/show"
      expect(response).to have_http_status(:success)
    end
  end
end
