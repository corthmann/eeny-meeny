require 'spec_helper'
require 'eeny-meeny/experiment'
require 'eeny-meeny/variation'

describe EenyMeeny::Experiment do
  describe 'when initialized' do

    context 'with weighted variations' do
      subject do
        described_class.new(:experiment_1,
                            name: 'Test 1',
                            variations: {
                                a: { name: 'A', weight: 0.5 },
                                b: { name: 'B', weight: 0.3 }})
      end

      it 'sets the instance variables' do
        expect(subject.id).to eq(:experiment_1)
        expect(subject.name).to eq('Test 1')
        expect(subject.variations).to be_a Array
        expect(subject.variations.size).to eq(2)
      end

      it "has a 'total_weight' equal to the sum of the variation weights" do
        expect(subject.total_weight).to eq(0.8)
      end

      describe '#pick_variation' do
        it 'picks a variation' do
          expect(subject.pick_variation).to be_a EenyMeeny::Variation
        end
      end
    end

    context 'with non-weighted variations' do
      subject do
        described_class.new(:experiment_1,
                            name: 'Test 1',
                            variations: {
                                a: { name: 'A' },
                                b: { name: 'B' }})
      end

      it 'sets the instance variables' do
        expect(subject.id).to eq(:experiment_1)
        expect(subject.name).to eq('Test 1')
        expect(subject.variations).to be_a Array
        expect(subject.variations.size).to eq(2)
      end

      it "has a 'total_weight' equal to the number of the variation weights" do
        expect(subject.total_weight).to eq(2)
      end

      describe '#pick_variation' do
        it 'picks a variation' do
          expect(subject.pick_variation).to be_a EenyMeeny::Variation
        end
      end
    end
  end
end
