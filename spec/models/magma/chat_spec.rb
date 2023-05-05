require 'spec_helper'
require 'rails_helper'

describe Magma::Chat do
  let(:chat) { Magma::Chat.new }

  describe '#initialize' do
    context 'with default settings' do
      it 'initializes with default parameters' do
        expect(chat.model).to eq('gpt-3.5-turbo')
        expect(chat.temperature).to eq(0.7)
        expect(chat.top_p).to eq(1.0)
        expect(chat.frequency_penalty).to eq(0.0)
        expect(chat.presence_penalty).to eq(0.0)
        expect(chat.max_tokens).to eq(500)
        expect(chat.stream).to be_nil
        expect(chat.debug).to be_falsey
      end
    end

    context 'with custom settings' do
      let(:custom_chat) do
        Magma::Chat.new(
          model: 'custom-model',
          temperature: 0.5,
          top_p: 0.9,
          frequency_penalty: 0.2,
          presence_penalty: 0.1,
          max_tokens: 300,
          stream: ->(response) { puts response },
          debug: true
        )
      end

      it 'initializes with custom parameters' do
        expect(custom_chat.model).to eq('custom-model')
        expect(custom_chat.temperature).to eq(0.5)
        expect(custom_chat.top_p).to eq(0.9)
        expect(custom_chat.frequency_penalty).to eq(0.2)
        expect(custom_chat.presence_penalty).to eq(0.1)
        expect(custom_chat.max_tokens).to eq(300)
        expect(custom_chat.stream).to be_a(Proc)
        expect(custom_chat.debug).to be_truthy
      end
    end
  end

  describe 'Magma::Chat::Message' do
    let(:message) { Magma::Chat::Message.new(role: :user, content: 'Hello') }

    it 'creates a message with the correct role and content' do
      expect(message.to_entry).to eq({ role: 'user', content: 'Hello' })
    end
  end

  describe '#prompt' do
    let(:key) { 'valid_key' }
    let(:content) { 'What is your name?' }
    let(:finish_reason) { 'stop' }

    before do
      allow(Magma::Prompts).to receive(:get).with("gpt.default_chat_directive").and_return("You are an assistant.")
      allow(Magma::Prompts).to receive(:get).with(key).and_return('What is your name?')

      # Mock the GPT client chat method to return a fixed response
      allow(Gpt.client).to receive(:chat).and_return(
        {
          "choices" => [
            {
              "message" => {
                "role" => "assistant",
                "content" => "As a language model, I don't have a name."
              },
              "finish_reason" => finish_reason
            }
          ]
        }
      )
    end

    it 'raises an error if neither key nor content is provided' do
      expect { chat.prompt }.to raise_error(ArgumentError)
    end

    it 'sends a prompt with key and returns the response' do
      response = chat.prompt(key: key)
      expect(response).to eq("As a language model, I don't have a name.")
    end

    it 'sends a prompt with content and returns the response' do
      response = chat.prompt(content: content)
      expect(response).to eq("As a language model, I don't have a name.")
    end

    it 'yields the response if a block is given' do
      chat.prompt(key: key) do |response|
        expect(response).to eq("As a language model, I don't have a name.")
      end
    end
  end
end
