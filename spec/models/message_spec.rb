# == Schema Information
#
# Table name: messages
#
#  id               :uuid             not null, primary key
#  content          :text
#  properties       :jsonb            not null
#  rating           :integer          default(0), not null
#  role             :string
#  sender_image_url :string
#  sender_name      :string
#  sender_type      :string
#  tokens_count     :integer          default(0), not null
#  visible          :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  chat_id          :uuid             not null
#  sender_id        :uuid
#
# Indexes
#
#  index_messages_on_chat_id  (chat_id)
#  index_messages_on_role     (role)
#  index_messages_on_sender   (sender_type,sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_id => chats.id)
#
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
    let(:instance) { build(:message, role: "user") }

    it 'returns role', :aggregate_failures do
      expect(instance.role).to be_a ActiveSupport::StringInquirer
      expect(instance.role.user?).to eq true
    end

    it 'sets strategy' do
      expect(instance.strategy).to be_kind_of(Message::UserStrategy)
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

  describe '#to_partial_path' do
    subject(:result) { described_class.new.to_partial_path }

    it { is_expected.to eq 'messages/message' }
  end

  describe '#reanalyze' do
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
