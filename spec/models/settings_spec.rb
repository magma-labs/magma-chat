require 'rails_helper'

RSpec.describe Settings, type: :model do
  let(:bot) { create(:bot) }

  describe 'delegation' do
    it 'delegates missing reader to the settings' do
      # true is the default in settings/bot.yml
      expect(bot.humanize).to eq(true)
    end

    it 'delegates missing writer to the settings' do
      bot.humanize = false
      bot.save!
      expect(bot.reload.humanize).to eq(false)
    end

    it 'correctly handles casting to boolean' do
      bot.humanize = "0"
      bot.save!
      expect(bot.reload).to_not be_humanize
      expect(bot.reload.humanize).to eq(false)
    end
  end
end
