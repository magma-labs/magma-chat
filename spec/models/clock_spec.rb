require 'rails_helper'

RSpec.describe Clock, type: :model do
  describe '#tick' do
    it 'outputs "tick\n"' do
      expect { described_class.new.tick }.to output("tick\n").to_stdout
    end
  end
end
