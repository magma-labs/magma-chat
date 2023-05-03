require 'rails_helper'

RSpec.describe HomeController, type: :request do
  before { allow(Gpt).to receive(:chat) }

  describe 'GET /index' do
    let(:user) { nil }

    before do
      login_user(user)

      get home_index_url
    end

    it 'responds with http 200' do
      expect(response).to have_http_status :ok
    end

    context 'when logged in' do
      let(:user) { create(:user) }

      it 'redirects to chats' do
        expect(response).to redirect_to chats_url
      end
    end
  end
end
