require 'eeny-meeny/middleware'
require 'eeny-meeny/helpers/experiment_helper'
require 'eeny-meeny/models/experiment'
require 'eeny-meeny/models/variation'
require 'eeny-meeny/models/cookie'
require 'rack/test'

describe EenyMeeny::ExperimentHelper, experiments: true do

  subject do
    Object.new.extend(EenyMeeny::ExperimentHelper)
  end

  let(:app) { EenyMeeny::Middleware.new(MockRackApp.new) }
  let(:experiment) { EenyMeeny::Experiment.find_by_id(:my_page) }

  describe '#participates_in?' do
    context 'given an experiment id' do
      context 'of an active experiment' do
        context 'with a valid experiment cookie' do
          it "returns the user's experiment variation" do
            get '/test'
            allow(subject).to receive(:cookies).and_return(current_session.cookie_jar)
            expect(subject.participates_in?(:my_page)).to be_a EenyMeeny::Variation
          end

          context 'and given a variation id' do
            context 'that matches the variation id the cookie' do
              it "returns the user's experiment variation" do
                get '/test' , EenyMeeny::Cookie.cookie_name(experiment) => :new
                allow(subject).to receive(:cookies).and_return(current_session.cookie_jar)
                expect(subject.participates_in?(:my_page, variation_id: :new)).to be_a EenyMeeny::Variation
                expect(subject.participates_in?(:my_page, variation_id: 'new')).to be_a EenyMeeny::Variation
              end
            end

            context 'that does not match the variation id the cookie' do
              it 'returns nil' do
                get '/test', EenyMeeny::Cookie.cookie_name(experiment) => :new
                allow(subject).to receive(:cookies).and_return(current_session.cookie_jar)
                expect(subject.participates_in?(:my_page, variation_id: :old)).to be_nil
                expect(subject.participates_in?(:my_page, variation_id: 'old')).to be_nil
              end
            end
          end
        end

        context 'without an experiment cookie' do
          it 'returns nil' do
            allow(subject).to receive(:cookies).and_return({})
            expect(subject.participates_in?(:my_page)).to be_nil
          end
        end
      end

      context 'of an inactive experiment' do
        context 'with a valid experiment cookie' do
          let(:experiment) { EenyMeeny::Experiment.find_by_id(:expired) }
          let(:cookie_jar) do
            {
              "#{EenyMeeny::Cookie.cookie_name(experiment)}" => EenyMeeny::Cookie.create_for_experiment(experiment).to_s
            }
          end

          it 'returns nil' do
            allow(subject).to receive(:cookies).and_return(cookie_jar)
            expect(subject.participates_in?(:expired)).to be_nil
          end
        end
      end

      context 'that does not exist among the experiments' do
        it 'returns nil' do
          get '/test'
          allow(subject).to receive(:cookies).and_return(current_session.cookie_jar)
          expect(subject.participates_in?(:this_does_not_exist)).to be_nil
        end
      end
    end
  end

  describe '#smoke_test?' do
    context 'given a smoke test id' do
      context 'and a request with a valid smoke test cookie' do
        it 'returns the smoke test' do
          get '/test', smoke_test_id: "my_smoke_test"
          allow(subject).to receive(:cookies).and_return(current_session.cookie_jar)
          expect(subject.smoke_test?(:my_smoke_test)).to be
        end
      end

      context 'and a request without a smoke test cookie' do
        it 'returns nil' do
          allow(subject).to receive(:cookies).and_return({})
          expect(subject.smoke_test?(:my_smoke_test)).to be_nil
        end
      end
    end
  end

end
