require 'rails_helper'

RSpec.describe "Settings", type: :request do
  let(:user) { create(:user) }

  before { login_user(user) }

  describe "GET /show" do
    xit "returns http success" do
      get "/settings/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /settings' do
    let(:params) do
      {
        user: {
          preferred_language: 'Baby Talk'
        }
      }
    end

    it 'updates user settings', :aggregate_failures do
      patch settings_url, params: params

      expect(response).to redirect_to settings_path
      expect(flash[:notice]).to eq('Settings updated')
      expect(user.reload.settings.new_setting).to eq params.dig(:user, :new_setting)
    end
  end
end
