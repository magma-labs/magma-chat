require 'rails_helper'

RSpec.describe ChatsController, type: :request do
  before { allow(Gpt).to receive(:chat) }

  shared_examples_for 'logged out' do
    context 'when logged out' do
      let(:user) { nil }

      it 'redirects to home' do
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'GET /index' do
    before do
      login_user(user)

      get chats_url
    end

    it_behaves_like 'logged out'

    context 'when user has chats' do
      let(:user) do
        user = create(:user)
        create(:chat, user: user)

        user
      end

      it 'responds with http 200' do
        expect(response).to have_http_status :ok
      end
    end

    context 'when user has no chats' do
      let(:user) { create(:user) }

      it 'redirects to chats' do
        expect(response).to redirect_to new_chat_url
      end
    end
  end

  describe 'GET /chats/:id' do
    let(:user) { chat.user }
    let(:chat) { create(:chat) }

    before do
      login_user(user)

      get chats_url(chat)
    end

    it_behaves_like 'logged out'

    it 'responds with http 200' do
      expect(response).to have_http_status :ok
    end
  end

  describe 'read only chat' do
    let(:chat) { create(:chat, :public) }

    shared_examples_for 'readonly requests' do
      it 'responds with http 200' do
        expect(response).to have_http_status :ok
      end

      context 'when chat is not public' do
        let(:chat) { create(:chat, public_access: false) }

        it 'redirects to /', :aggregate_failures do
          expect(response).to redirect_to root_path
          expect(flash[:notice]).to eq 'Chat not found'
        end
      end

      context 'when chat is not found' do
        let(:chat) { instance_double(Chat, id: '1234') }

        it 'redirects to /', :aggregate_failures do
          expect(response).to redirect_to root_path
          expect(flash[:notice]).to eq 'Chat not found'
        end
      end
    end

    describe 'GET /chats/:id/readonly' do
      before { get readonly_chat_url(id: chat.id) }

      it_behaves_like 'readonly requests'
    end

    describe 'GET /c/:id' do
      before { get readonly_url(id: chat.id) }

      it_behaves_like 'readonly requests'
    end
  end
end
