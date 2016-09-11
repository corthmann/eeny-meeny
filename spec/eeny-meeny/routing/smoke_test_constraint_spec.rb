require 'eeny-meeny/routing/smoke_test_constraint'
require 'eeny-meeny/middleware'
require 'rack/test'

describe EenyMeeny::SmokeTestConstraint do

  let(:request) do
    Rack::MockSession.new(EenyMeeny::Middleware.new(MockRackApp.new))
  end

  let(:request_with_cookie) do
    request.set_cookie('smoke_test_shadow_v1=kqe%2Bt%2F72JZ9s7fOv0nQ8GszTEmmXj3tUsjqmqy31i4yZLku5okuya%2F3PYb8Oi%2BSi53hDP8egfeiCcbrlBN4s5ifQwToaZHNAs43V1EKb8ca%2BTRK0lpCWfR58%2BQjpWwZL; expires=Tue, 11 Oct 2016 13:30:31 -0000; HttpOnly')
    request
  end

  describe 'when initialized' do

    subject do
      described_class.new(:shadow)
    end

    describe '#matches?' do
      context 'for a request with a valid smoke test cookie' do
        it 'returns true' do
          expect(subject.matches?(request_with_cookie)).to be true
        end
      end
      context 'for a request without a smoke test cookie' do
        it 'returns false' do
          expect(subject.matches?(request)).to be false
        end
      end
    end
  end
end
