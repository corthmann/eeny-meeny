require 'spec_helper'
require 'eeny-meeny/experiment_helper'
require 'eeny-meeny/models/variation'
require 'rack/test'

describe EenyMeeny::ExperimentHelper, type: :helper, experiments: true do

  subject do
    Object.new.extend(EenyMeeny::ExperimentHelper)
  end

  let(:request) do
    Rack::MockSession.new(EenyMeeny::Middleware.new(MockRackApp.new))
  end

  describe '#participates_in?' do
    context 'given an experiment id' do
      let(:request_with_cookie) do
        request.set_cookie(EenyMeeny::Cookie.create_for_experiment(EenyMeeny::Experiment.find_by_id(:my_page)).to_s)
        request
      end

      context 'of an active experiment' do
        context 'with a valid experiment cookie' do
          it "returns the user's experiment variation" do
            allow(subject).to receive(:cookies).and_return(request_with_cookie.cookie_jar)
            expect(subject.participates_in?(:my_page)).to be_a EenyMeeny::Variation
          end
        end

        context 'without an experiment cookie' do
          it 'returns nil' do
            allow(subject).to receive(:cookies).and_return(request.cookie_jar)
            expect(subject.participates_in?(:my_page)).to be_nil
          end
        end
      end

      context 'of an inactive experiment' do
        context 'with a valid experiment cookie' do
          let(:request_with_expired_cookie) do
            request.set_cookie(EenyMeeny::Cookie.create_for_experiment(EenyMeeny::Experiment.find_by_id(:expired)).to_s)
            request
          end

          it 'returns nil' do
            allow(subject).to receive(:cookies).and_return(request_with_expired_cookie.cookie_jar)
            expect(subject.participates_in?(:expired)).to be_nil
          end
        end
      end

      context 'that does not exist among the experiments' do
        it 'returns nil' do
          allow(subject).to receive(:cookies).and_return(request_with_cookie.cookie_jar)
          expect(subject.participates_in?(:this_does_not_exist)).to be_nil
        end
      end
    end
  end

  describe '#smoke_test?' do
    context 'given a smoke test id' do
      let(:request_with_smoke_test) do
        request.set_cookie(EenyMeeny::Cookie.create_for_smoke_test(:my_smoke_test).to_s)
        request
      end

      context 'and a request with a valid smoke test cookie' do
        it 'returns the smoke test' do
          allow(subject).to receive(:cookies).and_return(request_with_smoke_test.cookie_jar)
          expect(subject.smoke_test?(:my_smoke_test)).to be
        end
      end

      context 'and a request without a smoke test cookie' do
        it 'returns nil' do
          allow(subject).to receive(:cookies).and_return(request.cookie_jar)
          expect(subject.smoke_test?(:my_smoke_test)).to be_nil
        end
      end
    end
  end

end
