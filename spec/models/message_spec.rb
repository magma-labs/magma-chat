require 'rails_helper'

RSpec.describe Message, type: :model do
  before do
    allow(Gpt).to receive(:chat)
  end

  describe '#broadcast_message' do
    let(:instance) do
      described_class.new(
        role: role,
        chat: create(:chat),
        content: :content,
        visible: true
      )
    end

    let(:role) { :user }

    it 'schedules ChatPromptJob' do
      expect {
        instance.broadcast_message
      }.to have_enqueued_job(ChatPromptJob).with(instance.chat, instance.content, instance.visible)
    end

    context 'when it not "user" role' do
      let(:role) { :not_user }

      it 'does not schedule ChatPromptJob' do
        expect {
          instance.broadcast_message
        }.to_not have_enqueued_job(ChatPromptJob)
      end
    end
  end

  describe '#role' do
    let(:instance) { build(:message) }

    it 'returns role', :aggregate_failures do
      expect(instance.role).to be_a ActiveSupport::StringInquirer
      expect(instance.role.user?).to eq true
    end
  end

  describe '#sender=' do
    let(:instance) do
      described_class.new
    end

    let(:sender) { create(:user) }

    it 'sets sender attributes', :aggregate_failures do
      instance.sender = sender

      expect(instance.sender_name).to eq sender.name
      expect(instance.sender_image_url).to eq sender.image_url
    end
  end

  describe '#reanalize' do
    let(:message) { create(:message) }
    let(:chat) { message.chat }

    before do
      allow(chat).to receive_message_chain(:messages, :length).and_return(message_count)
    end

    context 'when messages count is a multiple of 4 plus 2' do
      let(:message_count) { 2 }

      it 'enqueues a ChatObservationJob' do
        expect { message.send(:reanalyze) }.to have_enqueued_job(ChatObservationJob).with(chat)
      end
    end

    context 'when messages count is a multiple of 6 plus 4' do
      let(:message_count) { 4 }

      it 'enqueues a ChatAnalysisJob' do
        expect { message.send(:reanalyze) }.to have_enqueued_job(ChatAnalysisJob).with(chat)
      end
    end
  end
end
