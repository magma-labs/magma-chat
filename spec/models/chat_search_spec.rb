require 'rails_helper'

RSpec.describe ChatSearch do
  describe '.message_content' do
    subject(:instance) { described_class.message_content(user, query) }

    let(:user) { create(:user) }
    let(:query) { message_content.split(' ').first }
    let(:chat) { create(:chat, message_count: 1, user: user) }
    let(:message_content) { chat.messages.last.content }

    before do
      allow(Gpt).to receive(:chat)
      allow_any_instance_of(Chat).to receive(:add_context_messages)

      chat
    end

    it 'returns an instance with results', :aggregate_failures do
      expect(message_content).to include query
      expect(instance.query).to eq query
      expect(instance.results.count).to eq 1

      first_result = instance.results.first

      expect(first_result).to be_a OpenStruct
      expect(first_result.messages.count).to eq 1
      expect(first_result.chat).to eq chat
      expect(first_result.messages).to eq chat.messages
      expect(first_result.to_partial_path).to eq 'chats/result'
    end

    context 'when no message is found' do
      let(:query) { 'NoResults' }

      it 'returns an instance with no results' do
        expect(message_content).to_not include query

        expect(instance.query).to eq query
        expect(instance.results).to eq []
      end
    end
  end

  describe '.tag' do
    subject(:instance) { described_class.tag(query) }

    let(:query) { 'query' }
    let(:chat) { build(:chat) }

    before do
      allow(Chat).to receive(:search_tags).with(query).and_return([chat])
    end

    it 'initializes an instance', :aggregate_failures do
      expect(instance.query).to eq "tag: #{query}"
      expect(instance.results).to eq [
        OpenStruct.new(chat: chat, messages: [], to_partial_path: 'chats/result')
      ]
    end
  end
end
