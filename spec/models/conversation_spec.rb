# == Schema Information
#
# Table name: conversations
#
#  id                   :uuid             not null, primary key
#  analysis             :jsonb            not null
#  grow                 :boolean          default(FALSE), not null
#  last_analysis_at     :datetime
#  last_observations_at :datetime
#  public_access        :boolean          default(FALSE), not null
#  settings             :jsonb            not null
#  title                :string           not null
#  transcript           :jsonb            not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  bot_id               :uuid
#  user_id              :uuid             default("b48d0808-271f-451e-a190-8610009df363"), not null
#
# Indexes
#
#  index_conversations_on_bot_id         (bot_id)
#  index_conversations_on_public_access  (public_access)
#  index_conversations_on_title          (title)
#  index_conversations_on_user_id        (user_id)
#
require 'rails_helper'

RSpec.describe Conversation do
  before do
    allow(Gpt).to receive(:chat)
  end

  describe '#directive' do
    let(:conversation) { build(:conversation) }

    it 'delegates directive to bot' do
      expect(conversation.full_directive).to eq conversation.bot.full_directive
    end
  end

  describe '#bot' do
    let(:conversation) { build(:conversation, bot: nil) }
    let(:bot) { Bot.default }

    it 'returns default bot id' do
      expect(conversation.bot).to eq bot
    end

    context 'when bot is present' do
      let(:conversation) { create(:conversation) }
      let(:bot) { conversation.bot }

      it 'returns assigned bot' do
        expect(conversation.bot_id).to eq bot.id
      end
    end
  end

  describe '#bot_id' do
    let(:conversation) { build(:conversation, bot: nil) }
    let(:bot) { Bot.default }

    it 'returns default bot id' do
      expect(conversation.bot_id).to eq bot.id
    end

    context 'when bot is present' do
      let(:conversation) { create(:conversation) }
      let(:bot) { conversation.bot }

      it 'returns assigned bot id' do
        expect(conversation.bot_id).to eq bot.id
      end
    end
  end

  describe '#prompt!' do
    let(:conversation) { create(:conversation) }

    let(:sender) { conversation.user }
    let(:message) { 'Message!' }
    let(:visible) { true }

    it 'creates a message', :aggregate_failures do
      expect { conversation.prompt!(message: message, visible: visible, sender: sender) }
        .to change(conversation.messages, :count).by(1)
    end
  end

  describe '#redo!' do
    let(:user) { create(:user) }
    let(:bot) { create(:bot) }
    let(:conversation) { create(:conversation, bot: bot, user: user) }

    it 'deletes last messages and calls prompt! with message', :aggregate_failures do
      conversation.user_message!("Foo")
      conversation.bot_message!("Bar")
      conversation.redo!(user, "Hello")
      expect(conversation.messages.count).to eq 2
    end
  end

  describe 'language' do
    let(:conversation) { build(:conversation, analysis: { language: language }) }
    let(:language) { 'english' }

    it 'returns language value from analysis' do
      expect(conversation.language).to eq language
    end
  end

  describe 'sentiment' do
    let(:conversation) { build(:conversation, analysis: { sentiment: sentiment }) }
    let(:sentiment) { 'sentiment' }

    it 'returns sentiment value from analysis' do
      expect(conversation.sentiment).to eq sentiment
    end
  end

  describe 'summary' do
    let(:conversation) { build(:conversation, analysis: { summary: summary }) }
    let(:summary) { 'summary' }

    it 'returns summary value from analysis' do
      expect(conversation.summary).to eq summary
    end
  end

  describe '#messages_for_gpt' do
    subject(:messages_for_gpt) { conversation.messages_for_gpt(token_limit: 400) }

    let(:conversation) { create(:conversation, message_count: 1) }
    let(:message) { conversation.messages.first }

    before do
      allow_any_instance_of(Conversation).to receive(:add_user_intro)
    end

    it 'returns an array of hashes with role and content', :aggregate_failures do
      expect(messages_for_gpt.count).to eq 1

      first_message = messages_for_gpt.first
      expect(first_message[:role]).to eq message.role
      expect(first_message[:content]).to eq message.content
    end
  end

  describe '#analysis_next' do
    let(:conversation) { build(:conversation, analysis: { next: analysis_next }) }
    let(:analysis_next) { 'analysis_next' }

    it 'returns next value analysis' do
      expect(conversation.analysis_next).to eq analysis_next
    end

    context 'when key is missing from analysis' do
      let(:analysis_next) { nil }

      it 'returns an empty array' do
        expect(conversation.analysis_next).to eq []
      end
    end
  end

  describe '#tags' do
    let(:conversation) { build(:conversation, analysis: { tags: tags }) }
    let(:tags) { ['tag1', 'tag2'] }

    it 'returns tags value from analysis' do
      expect(conversation.tags).to eq tags
    end

    context 'when key is missing from analysis' do
      let(:tags) { nil }

      it 'returns an empty array' do
        expect(conversation.tags).to eq []
      end
    end
  end

  describe '#add_user_intro' do
    let(:conversation) { create(:conversation, message_count: 2) }

    let(:context_user_prompt) do
      Magma::Prompts.get('conversations.context_intro', {
        bot_name: conversation.bot.name,
        bot_role: conversation.bot.role,
        user_name: conversation.user.name,
        date: Date.today.strftime("%B %d, %Y"),
        time: Time.now.strftime("%I:%M %p")
      })
    end

    before do
      expect_any_instance_of(Conversation).to receive(:add_user_intro).and_call_original
    end

    it 'creates context messages', :aggregate_failures do
      expect(conversation.messages.count).to eq 3 # 2 messages + 1 context message
    end
  end

  describe '#set_title' do
    let(:conversation) { create(:conversation, title: nil, first_message: message) }
    let(:message) { 'Hello World!' }

    it 'sets first_message as the title' do
      expect(conversation.title).to eq message
    end

    context 'when first_message is not present' do
      let(:message) { nil }

      it 'sets a default title' do
        expect(conversation.title).to eq "Conversation with #{conversation.bot.name}"
      end
    end
  end
end
