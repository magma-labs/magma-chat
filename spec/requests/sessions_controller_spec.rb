require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  describe 'GET /auth/:provider/callback' do
    let(:params) { { provider: :google } }
    let(:user) { create(:user) }

    before do
      mock_omniauth(user)

      get '/auth/:provider/callback', params: params
    end

    it 'signs the user in', :aggregate_failures do
      expect(response).to redirect_to '/chats'
      expect(flash[:notice]).to eq 'Signed in!'
      expect(session[:user_id]).to eq user.id
    end
  end

  describe 'GET /logout' do
    it 'signs the user out' do
      get logout_url

      expect(response).to redirect_to root_url
      expect(flash[:notice]).to eq 'Signed out!'
      expect(session[:user_id]).to eq nil
    end
  end
end
