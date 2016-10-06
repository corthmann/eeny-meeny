require 'eeny-meeny/routing/experiment_constraint'
require 'eeny-meeny/middleware'
require 'rack/test'

describe EenyMeeny::ExperimentConstraint, experiments: true do

  let(:request) do
    session = Rack::MockSession.new(EenyMeeny::Middleware.new(MockRackApp.new))
    session.set_cookie('eeny_meeny_my_page_v1=ctRsrHCj21pZt%2FELsjedHRT9GkYOuIdoTwEyP9kxfI7dDS4I9g1nv77j9Umij1P44SCU7Zebdb8mqwLabTrskg%3D%3D; path=/; expires=Sun, 06 Nov 2016 11:26:01 -0000; HttpOnly')
    session
  end

  describe 'when initialized' do

    context 'for an inactive experiment' do
      subject do
        described_class.new(:expired)
      end

      describe '#matches?' do
        it 'returns false' do
          expect(subject.matches?(request)).to be false
        end
      end
    end

    context 'for an active experiment' do
      subject do
        described_class.new(:my_page)
      end

      describe '#matches?' do
        it 'returns true' do
          expect(subject.matches?(request)).to be true
        end
      end
    end
  end
end
