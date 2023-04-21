require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  describe '.list_to_text' do
    subject { Agent.new }

    let(:attr_name) { :goals }

    it 'defines a getter method for the attribute text' do
      expect(subject).to respond_to("#{attr_name}_text")
    end

    it 'defines a setter method for the attribute text' do
      expect(subject).to respond_to("#{attr_name}_text=")
    end

    it 'sets the attribute from text' do
      subject.send("#{attr_name}_text=", "item 1\n\nitem 2\n\nitem 3\n\n")

      expect(subject.send(attr_name)).to eq(['item 1', 'item 2', 'item 3'])
    end

    it 'gets the attribute as text' do
      subject.send("#{attr_name}=", ['item 1', 'item 2', 'item 3'])

      expect(subject.send("#{attr_name}_text")).to eq("item 1\n\nitem 2\n\nitem 3")
    end
  end
end
