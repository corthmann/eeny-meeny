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

          context 'and given a variation id' do
            let(:request_with_variation_cookie) do
              request.set_cookie(EenyMeeny::Cookie.create_for_experiment_variation(EenyMeeny::Experiment.find_by_id(:my_page), :new).to_s)
              request
            end

            context 'that matches the variation id the cookie' do
              it "returns the user's experiment variation" do
                allow(subject).to receive(:cookies).and_return(request_with_variation_cookie.cookie_jar)
                expect(subject.participates_in?(:my_page, variation_id: :new)).to be_a EenyMeeny::Variation
                expect(subject.participates_in?(:my_page, variation_id: 'new')).to be_a EenyMeeny::Variation
              end
            end

            context 'that does not match the variation id the cookie' do
              it 'returns nil' do
                allow(subject).to receive(:cookies).and_return(request_with_variation_cookie.cookie_jar)
                expect(subject.participates_in?(:my_page, variation_id: :old)).to be_nil
                expect(subject.participates_in?(:my_page, variation_id: 'old')).to be_nil
              end
            end
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

    describe 'with a smoke test dependency' do
      describe 'and activated smoke test' do
        context 'given an experiment id' do
          let(:request_with_cookie) do
            request.set_cookie(EenyMeeny::Cookie.create_for_smoke_test(:smoke_flag).to_s)
            request.set_cookie(EenyMeeny::Cookie.create_for_experiment(EenyMeeny::Experiment.find_by_id(:my_page_smoke_test_dependent)).to_s)
            request
          end

          context 'of an active experiment' do
            context 'with a valid experiment cookie' do
              it "returns the user's experiment variation" do
                allow(subject).to receive(:cookies).and_return(request_with_cookie.cookie_jar)
                expect(subject.participates_in?(:my_page_smoke_test_dependent)).to be_a EenyMeeny::Variation
              end

              context 'and given a variation id' do
                let(:request_with_variation_cookie) do
                  request.set_cookie(EenyMeeny::Cookie.create_for_experiment_variation(EenyMeeny::Experiment.find_by_id(:my_page_smoke_test_dependent), :new).to_s)
                  request
                end

                context 'that matches the variation id the cookie' do
                  it "returns the user's experiment variation" do
                    allow(subject).to receive(:cookies).and_return(request_with_variation_cookie.cookie_jar)
                    expect(subject.participates_in?(:my_page_smoke_test_dependent, variation_id: :new)).to be_a EenyMeeny::Variation
                    expect(subject.participates_in?(:my_page_smoke_test_dependent, variation_id: 'new')).to be_a EenyMeeny::Variation
                  end
                end

                context 'that does not match the variation id the cookie' do
                  it 'returns nil' do
                    allow(subject).to receive(:cookies).and_return(request_with_variation_cookie.cookie_jar)
                    expect(subject.participates_in?(:my_page_smoke_test_dependent, variation_id: :old)).to be_nil
                    expect(subject.participates_in?(:my_page_smoke_test_dependent, variation_id: 'old')).to be_nil
                  end
                end
              end
            end

            context 'without an experiment cookie' do
              it 'returns nil' do
                allow(subject).to receive(:cookies).and_return(request.cookie_jar)
                expect(subject.participates_in?(:my_page_smoke_test_dependent)).to be_nil
              end
            end
          end
        end
      end

      describe 'and innactived smoke test' do
        context 'given an experiment id' do
          let(:request_with_cookie) do
            request.set_cookie(EenyMeeny::Cookie.create_for_experiment(EenyMeeny::Experiment.find_by_id(:my_page_smoke_test_dependent)).to_s)
            request
          end

          context 'of an active experiment' do
            context 'with a valid experiment cookie' do
              it "returns the user's experiment variation" do
                allow(subject).to receive(:cookies).and_return(request_with_cookie.cookie_jar)
                expect(subject.participates_in?(:my_page_smoke_test_dependent)).to be_a EenyMeeny::Variation
              end

              context 'and given a variation id' do
                let(:request_with_variation_cookie) do
                  request.set_cookie(EenyMeeny::Cookie.create_for_experiment_variation(EenyMeeny::Experiment.find_by_id(:my_page), :new).to_s)
                  request
                end

                context 'that matches the variation id the cookie' do
                  it "returns nil as variation" do
                    allow(subject).to receive(:cookies).and_return(request_with_variation_cookie.cookie_jar)
                    expect(subject.participates_in?(:my_page_smoke_test_dependent, variation_id: :new)).to be_nil
                    expect(subject.participates_in?(:my_page_smoke_test_dependent, variation_id: 'new')).to be_nil
                  end
                end

                context 'that does not match the variation id the cookie' do
                  it 'returns nil' do
                    allow(subject).to receive(:cookies).and_return(request_with_variation_cookie.cookie_jar)
                    expect(subject.participates_in?(:my_page_smoke_test_dependent, variation_id: :old)).to be_nil
                    expect(subject.participates_in?(:my_page_smoke_test_dependent, variation_id: 'old')).to be_nil
                  end
                end
              end
            end

            context 'without an experiment cookie' do
              it 'returns nil' do
                allow(subject).to receive(:cookies).and_return(request.cookie_jar)
                expect(subject.participates_in?(:my_page_smoke_test_dependent)).to be_nil
              end
            end
          end
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
