require 'spec_helper'
require 'eeny-meeny/models/variation'

describe EenyMeeny::Variation do
  describe 'when initialized' do

    subject do
      described_class.new(:a,
                          name: 'A',
                          weight: 0.5,
                          custom_option_1: 'asd1',
                          custom_option_2: 'asd2')
    end

    it "sets the 'id'" do
      expect(subject.id).to eq(:a)
    end

    it "sets the 'name'" do
      expect(subject.name).to eq('A')
    end

    it "sets the 'weight'" do
      expect(subject.weight).to eq(0.5)
    end

    it "sets the custom 'options'" do
      expect(subject.options).to be_a Hash
      expect(subject.options[:custom_option_1]).to eq('asd1')
      expect(subject.options[:custom_option_2]).to eq('asd2')
    end

    describe '#marshal_dump' do
      it 'can load a marshal dump correctly' do
        dump = Marshal.dump(subject)
        expect(dump).to be_a String
        loaded_object = Marshal.load(dump)
        expect(loaded_object).to_not be_a String
        expect(loaded_object).to be_a EenyMeeny::Variation
        expect(loaded_object.id).to eql(:a)
        expect(loaded_object.name).to eq('A')
        expect(loaded_object.weight).to eq(0.5)
        expect(loaded_object.options[:custom_option_1]).to eq('asd1')
      end
    end
  end


end
