require 'rails_helper'

RSpec.describe ConversationSearch do
  describe '.message_content' do
    subject(:instance) { described_class.message_content(user, query) }

    let(:user) { create(:user) }
    let(:query) { message_content.split(' ').first }
    let(:conversation) { create(:conversation, message_count: 1, user: user) }
    let(:message_content) { conversation.messages.last.content }

    before do
      allow(Gpt).to receive(:chat)
      allow_any_instance_of(Conversation).to receive(:add_context_messages)

      conversation
    end

    it 'returns an instance with results', :aggregate_failures do
      expect(message_content).to include query
      expect(instance.query).to eq query
      expect(instance.results.count).to eq 1

      first_result = instance.results.first

      expect(first_result).to be_a OpenStruct
      expect(first_result.messages.count).to eq 1
      expect(first_result.conversation).to eq conversation
      expect(first_result.messages).to eq conversation.messages
      expect(first_result.to_partial_path).to eq 'conversations/result'
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
    let(:conversation) { build(:conversation) }

    before do
      allow(Conversation).to receive(:search_tags).with(query).and_return([conversation])
    end

    it 'initializes an instance', :aggregate_failures do
      expect(instance.query).to eq "tag: #{query}"
      expect(instance.results).to eq [
        OpenStruct.new(conversation: conversation, messages: [], to_partial_path: 'conversations/result')
      ]
    end
  end
end
