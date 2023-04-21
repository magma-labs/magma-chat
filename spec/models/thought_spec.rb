require 'rails_helper'

RSpec.describe Thought, type: :model do
  before { allow(Gpt).to receive(:chat) }

  describe '#brief_with_timestamp' do
    let(:instance) do
      described_class.new(
        brief: '  brief.  ',
        created_at: timestamp
      )
    end

    let(:timestamp) { Time.current }

    let(:expected_value) { "[#{timestamp.strftime('%d/%m/%Y %H:%M')}]:brief" }

    it 'concatenates timestamp with brief' do
      expect(instance.brief_with_timestamp).to eq expected_value
    end
  end

  describe '#store_vector' do
    let(:instance) { create(:thought) }
    let(:marqo_client) { double(:marqo_client) }

    before do
      allow(Marqo).to receive(:client).and_return(marqo_client)
    end

    let(:document) do
      instance.content.merge(
        instance.attributes.symbolize_keys.slice(
          :type,
          :brief,
          :bot_id,
          :subject_id,
          :subject_type,
          :importance
        )
      )
    end

    let(:expected_args) do
      {
        index: described_class::INDEX,
        id: instance.id,
        doc: document,
        non_tensor_fields: [:type, :bot_id, :subject_id, :subject_type, :importance]
      }
    end

    it 'stores it in Marqo' do
      allow(marqo_client).to receive(:store)

      instance

      expect(marqo_client)
        .to have_received(:store)
        .with(expected_args)
    end

    context 'when Marqo request fails' do
      let(:message) { "Failed to store vector for thought #{instance.id}" }

      it 'logs an error' do
        allow(marqo_client).to receive(:store).and_raise 'Failed'
        expect(Rails.logger).to receive(:error).with(message)

        instance.send(:store_vector)
      end
    end
  end

  describe '#delete_vector' do
    let(:instance) { create(:thought) }
    let(:marqo_client) { double(:marqo_client) }

    before do
      allow(marqo_client).to receive(:store)
      allow(marqo_client).to receive(:delete)

      allow(Marqo).to receive(:client).and_return(marqo_client)
    end

    it 'deletes from Marqo' do
      instance.send(:delete_vector)

      expect(marqo_client)
        .to have_received(:delete)
        .with(described_class::INDEX, instance.id)
    end

    context 'when Marqo request fails' do
      let(:message) { "Failed to delete vector for thought #{instance.id}" }

      it 'logs an error' do
        allow(marqo_client).to receive(:delete).and_raise 'Failed'
        expect(Rails.logger).to receive(:error).with(message)

        instance.send(:delete_vector)
      end
    end
  end
end
