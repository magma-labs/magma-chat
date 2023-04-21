require 'rails_helper'

RSpec.describe Bot do
  shared_examples_for 'robohash image url' do
    let(:instance) { build(:bot) }

    it 'generates an image url' do
      expect(subject).to eq "https://robohash.org/#{instance.name}.png?size=640x640&set=set1"
    end
  end

  describe '#image_url' do
    subject { instance.image_url }

    it_behaves_like 'robohash image url'
  end

  describe '#generated_image_url' do
    subject { instance.generated_image_url }

    it_behaves_like 'robohash image url'
  end

  describe '#observed!' do
    let(:chat) { create(:chat) }
    let(:bot) { create(:bot) }

    let(:observations) do
      (1..5).map { |num| "Observation #{num}" }
    end

    before do
      allow(Gpt).to receive(:chat)
    end

    it 'creates observations with correct attributes', :aggregate_failures do
      expect { bot.observed!(chat, observations) }
        .to change(bot.observations, :count)
        .by(observations.count)

      bot.observations.each_with_index do |observation, i|
        expect(observation.subject).to eq(chat.user)
        expect(observation.brief).to eq(observations[i])
        expect(observation.importance).to be_between(0, 100)
      end
    end
  end

  describe '#to_partial_path' do
    subject { build(:bot).to_partial_path }

    it { is_expected.to eq 'bots/bot' }
  end

  describe '.default' do
    let(:last_bot) { Bot.last }
    let(:bot_intro_from_gpt) { 'Bot Intro from Chat GPT' }
    let(:prompt_double) { double('Prompt') }

    before do
      allow(Prompts).to receive(:get).and_return(prompt_double)
      allow(Gpt).to receive(:chat)
        .with(prompt: prompt_double, max_tokens: 120, temperature: 0.8)
        .and_return(bot_intro_from_gpt)
    end

    it 'creates a default bot', :aggregate_failures do
      expect { described_class.default }.to change(Bot, :count).by(1)

      expect(last_bot.name).to eq 'Gerald'
      expect(last_bot.role).to eq 'GPT Assistant'
      expect(last_bot.directive).to eq "You are a smart and friendly general purpose chatbot."
      expect(last_bot.intro).to eq bot_intro_from_gpt
      expect(last_bot.auto_archive_mins).to eq 0
    end
  end

  describe '.others' do
    let(:bot1) { create(:bot, name: 'B') }
    let(:bot2) { create(:bot, name: 'A') }

    before do
      allow(Gpt).to receive(:chat)

      described_class.default
      bot1
      bot2
    end

    it 'returns other bots' do
      expect(described_class.others).to eq [bot2, bot1]
    end
  end
end
