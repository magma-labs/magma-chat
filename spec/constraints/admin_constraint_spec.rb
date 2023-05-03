require 'rails_helper'

describe AdminConstraint, type: :routing do
  subject { described_class.matches?(request) }

  let(:request) { double('request') }

  before do
    allow(request).to receive(:session).and_return({
      user_id: user&.id
    })
  end

  context 'when user is not present' do
    let(:user) { nil }

    it { is_expected.to eq false }
  end

  context 'when user is not admin' do
    let(:user) { create(:user) }

    it { is_expected.to eq false }
  end

  context 'when user is admin' do
    let(:user) { create(:admin) }

    it { is_expected.to eq true }
  end
end
