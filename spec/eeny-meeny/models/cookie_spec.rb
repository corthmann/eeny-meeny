require 'spec_helper'
require 'eeny-meeny/models/cookie'
require 'eeny-meeny/models/experiment'

describe EenyMeeny::Cookie do
  describe 'when initialized' do
    subject do
      described_class.new(name: 'test', value: '12345')
    end

    it 'sets the instance variables correctly' do
      expect(subject.name).to eq('test')
      expect(subject.value).to eq('12345')
      expect(subject.expires).to be
      expect(subject.httponly).to be
      expect(subject.same_site).to be_nil
      expect(subject.path).to be_nil
    end

    describe '#to_h' do
      it 'returns cookie options' do
        options = subject.to_h
        expect(options).to be_a Hash
        expect(options.keys.sort).to eq([:value, :httponly, :expires].sort)
      end
    end
  end

  describe '.create_for_smoke_test' do
    context 'given a smoke test id' do
      it 'creates a cookie' do
        instance = described_class.create_for_smoke_test(:shadow)
        expect(instance).to be_a EenyMeeny::Cookie
        expect(instance.name).to eq(described_class.smoke_test_name(:shadow))
      end
    end
  end

  describe '.create_for_experiment', experiments: true do
    context 'given an experiment' do
      it 'creates a cookie' do
        experiment = EenyMeeny::Experiment.find_by_id(:my_page)
        instance = described_class.create_for_experiment(experiment)
        expect(instance).to be_a EenyMeeny::Cookie
        expect(instance.name).to eq(described_class.cookie_name(experiment))
      end

      context 'and given cookie options' do
        it 'creates a cookie with the given options' do
          experiment = EenyMeeny::Experiment.find_by_id(:my_page)
          instance = described_class.create_for_experiment(experiment, same_site: :fun_stuff)
          expect(instance).to be_a EenyMeeny::Cookie
          expect(instance.name).to eq(described_class.cookie_name(experiment))
          expect(instance.same_site).to eq(:fun_stuff)
        end
      end
    end
  end

  describe '.create_for_experiment_variation', experiments: true do
    context 'given an experiment and an variation id' do
      it 'creates a cookie for that variation' do
        experiment = EenyMeeny::Experiment.find_by_id(:my_page)
        instance = described_class.create_for_experiment_variation(experiment, :new)
        expect(instance).to be_a EenyMeeny::Cookie
        expect(instance.name).to eq(described_class.cookie_name(experiment))
        expect(described_class.read(instance.value)[:variation].id).to eq(:new)
      end

      context 'and given cookie options' do
        it 'creates a cookie for that variation with the given options' do
          experiment = EenyMeeny::Experiment.find_by_id(:my_page)
          instance = described_class.create_for_experiment_variation(experiment, :new, same_site: :fun_stuff)
          expect(instance).to be_a EenyMeeny::Cookie
          expect(instance.name).to eq(described_class.cookie_name(experiment))
          expect(instance.same_site).to eq(:fun_stuff)
          expect(described_class.read(instance.value)[:variation].id).to eq(:new)
        end
      end
    end
  end

  describe '.smoke_test_name' do
    context 'given a smoke_test_id' do
      it 'returns the smoke test cookie name' do
        expect(described_class.smoke_test_name(:something)).to eq('smoke_test_something_v1')
      end
    end
  end

  describe '.cookie_name', experiments: true do
    context 'given an experiment' do
      it 'returns the experiment cookie name' do
        experiment = EenyMeeny::Experiment.find_by_id(:my_page)
        expect(described_class.cookie_name(experiment)).to eq('eeny_meeny_my_page_v1')
      end
    end
  end

  describe '.read', experiments: true do
    context 'given an empty cookie string' do
      it 'returns nil' do
        expect(described_class.read(nil)).to be_nil
        expect(described_class.read('')).to be_nil
      end
    end

    context 'when EenyMeeny.config.secure = true' do
      context 'and given a valid cookie string' do
        it 'decrypts the string and returns the cookie hash' do
          valid_cookie_string = 'DhtZMLAtVpWiruuq6BdQ+YEeDTK4G1p0HQLeyKFZd2+fD8YyT004p56S03yXsE/kzCASnD9O1sk1tsIHDZ8W2gq+5zQD3fu2aqqLm461FOfy0En4/LqHCP0J0VYol3Py0BlhepjSGDuJrRU7TdKZWsG2/dCiMVLjMf0Pt00NZWooUvQfRz9SCzaFL0mywoVrY1ErKKQCNEPmLREaxavCng=='
          expect(described_class.read(valid_cookie_string)).to be_a Hash
        end
      end

      context 'and given an invalid cookie string' do
        it 'returns nil' do
          expect(described_class.read('qwedasdafagasdaasdasd')).to be_nil
        end
      end
    end

    # context 'when EenyMeeny.config.secure = false' do
    #   context 'and given a valid cookie string' do
    #     it 'returns the cookie hash' do
    #
    #     end
    #   end
    # end
  end
end
