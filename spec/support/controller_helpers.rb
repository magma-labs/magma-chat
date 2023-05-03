module ControllerHelpers
  def login_user(user)
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end

  def mock_omniauth(user)
    OmniAuth.config.test_mode = true
    omniauth_hash = Faker::Omniauth.google(name: user.name, uid: user.oauth_uid)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(omniauth_hash)
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
  end
end

shared_examples_for 'admin - forbidden' do
  context 'when logged out' do
    let(:user) { nil }

    it 'redirects to root' do
      expect(response).to redirect_to root_path
    end
  end

  context 'when logged in user is not admin' do
    let(:user) { create(:user) }

    it 'redirects to root' do
      expect(response).to redirect_to root_path
    end
  end
end
