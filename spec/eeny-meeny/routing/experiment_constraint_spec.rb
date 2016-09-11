require 'eeny-meeny/routing/experiment_constraint'
require 'eeny-meeny/middleware'
require 'rack/test'

describe EenyMeeny::ExperimentConstraint, experiments: true do

  let(:request) do
    session = Rack::MockSession.new(EenyMeeny::Middleware.new(MockRackApp.new))
    session.set_cookie('eeny_meeny_my_page_v1=IlI%2FGW9IZvayAGQbBOroxIrfr6Z116OJqdjFdrw6FOZXOrinmxQmsKw2a%2Fb8kJFP0Up%2BLr4FACovT9%2Bo0hRdcY0AJtcYqMXC96GDMSwa2HauZbjHw16Q3%2BboSnWjfaEOHmqlyxtPxQwxlr3rsT%2FYblPjqqQ%2FiPbaJUqou3LiMtpVg4V%2FJxJdhn0XJUgFMDaFWXVFYYA6VmJSFUGglhRlbg%3D%3D; path=/; expires=Tue, 11 Oct 2016 13:07:53 -0000; HttpOnly')
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
