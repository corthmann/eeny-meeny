require 'spec_helper'
require 'eeny-meeny/models/experiment'
require 'eeny-meeny/models/variation'

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

  describe '.find_all' do
    context 'when the EenyMeeny is configured with experiments', experiments: true do
      it 'returns those experiments' do
        instances = described_class.find_all
        expect(instances).to be_a Array
        expect(instances.size).to eq(1)
        instances.each do |instance|
          expect(instance).to be_a EenyMeeny::Experiment
        end
      end
    end

    context 'when EenyMeeny is not configured with experiments' do
      it 'returns an empty array' do
        expect(described_class.find_all).to eq([])
      end
    end
  end

  describe '.find_by_id' do
    context 'when EenyMeeny is configured with experiments', experiments: true do
      context 'and the given id exists' do
        it 'returns the experiment' do
          expect(described_class.find_by_id(:my_page)).to be_a EenyMeeny::Experiment
        end
      end

      context 'and the given id does not exist' do
        it 'returns nil' do
          expect(described_class.find_by_id(:experiment_missing)).to be_nil
        end
      end
    end

    context 'when EenyMeeny is not configured with experiments' do
      it 'returns nil' do
        expect(described_class.find_by_id(:experiment_missing)).to be_nil
      end
    end
  end

end
