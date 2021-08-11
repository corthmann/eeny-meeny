require 'eeny-meeny/models/encryptor'
require 'eeny-meeny/middleware'

def initialize_app(secure: true, secret: 'test', path: '/', same_site: :strict)
  EenyMeeny.reset!
  EenyMeeny.configure do |config|
    config.cookies     = { path: path, same_site: same_site }
    config.experiments = YAML.load_file(File.join('spec','fixtures','experiments.yml'))
    config.secret      = secret
    config.secure      = secure
  end
  described_class.new(app)
end

describe EenyMeeny::Middleware do

  let(:app) { MockRackApp.new }

  describe 'when initialized' do

    subject { initialize_app }

    it 'sets the experiments' do
      expect(subject.instance_variable_get(:@experiments)).to be
    end

    it 'sets the cookie config' do
      expect(subject.instance_variable_get(:@cookie_config)).to be
    end
  end

  describe 'when called with a GET request' do
    subject { initialize_app }

    context "and the request doesn't contain the experiment cookie" do
      let(:request) { Rack::MockRequest.new(subject) }

      before(:example) do
        @response = request.get('/test', 'CONTENT_TYPE' => 'text/plain')
      end

      it "sets the 'HTTP_COOKIE' header on the request" do
        expect(app['HTTP_COOKIE']).to be
        expect(app['HTTP_COOKIE'].length).to be > 0
      end

      it "sets the 'Set-Cookie' header on the response" do
        expect(@response['Set-Cookie']).to be
        expect(@response['Set-Cookie'].length).to be > 0
      end
    end

    context 'and the request already contains the experiment cookie' do
      let(:request) { Rack::MockRequest.new(subject) }

      before(:example) do
        @original_request_cookies = 'test=abc;eeny_meeny_my_page_v1=on1tOQ5hiKdA0biVZVwvTUQcmkODacwdpi%2FedQJIYQz9KdWYAXqzCafF5Dqqa6xtHFBdXYVmz%2Bp4%2FigmKz4hBVYZbJU%2FMwBbvYG%2BIoBelk10PxwtyxbA%2BiDzFT4jZeiTkNOmZ3rp1Gzz74JjT4aocqB187p7SrpeM2jfyZ8ZKPOiZs6tXf0QoXkV%2BZbtxJLRPr5lgmGxslfM8vCIm1%2F0HQ%3D%3D;eeny_meeny_versioned_v3=UUgXwn3j0%2BOL2cpov4duTnuCJPc621yHd6GjuXpN0gnYLDASTsDpyk01CnFY5ZYCAo%2BgLO%2BwTbsYObP8dp30rA%3D%3D;'
        @response = request.get('/test',
                                'CONTENT_TYPE' => 'text/plain',
                                'HTTP_COOKIE' => @original_request_cookies)
      end

      it "does not change the 'HTTP_COOKIE' header on the request" do
        expect(app['HTTP_COOKIE']).to eq(@original_request_cookies)
      end

      it "does not set the 'Set-Cookie' header on the response" do
        expect(@response['Set-Cookie']).to be nil
      end
    end

    context 'and the request contains a cookie from an undefined experiment' do
      let(:request) { Rack::MockRequest.new(subject) }
      let(:cookie_value) { 'eeny_meeny_undefined_experiment_v1=thevaluedoesntmatter' }
      let(:return_value) do
        "#{cookie_value}; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Strict"
      end

      before(:example) do
        @original_request_cookies = "test=abc;#{cookie_value};"
        @response = request.get('/test',
                                'CONTENT_TYPE' => 'text/plain',
                                'HTTP_COOKIE' => @original_request_cookies)
      end


      it "instructs the browser to remove through the 'Set-Cookie' header on the response" do
        expect(@response['Set-Cookie']).to include(return_value)
      end
    end

    context 'and given an experiment query parameter' do
      let(:request) { Rack::MockRequest.new(initialize_app(secure: false)) }

      before(:example) do
        @response = request.get('/test?eeny_meeny_my_page_v1=old', 'CONTENT_TYPE' => 'text/plain')
      end

      it 'selects the correct variation' do
        expect(app['HTTP_COOKIE']).to include('eeny_meeny_my_page_v1=old')
        expect(app['HTTP_COOKIE']).to_not include('eeny_meeny_my_page_v1=new')
      end

      it "sets the 'HTTP_COOKIE' header on the request" do
        expect(app['HTTP_COOKIE']).to be
        expect(app['HTTP_COOKIE']).to include('eeny_meeny_my_page_v1=')
      end

      it "sets the 'Set-Cookie' header on the response" do
        expect(@response['Set-Cookie']).to be
        expect(@response['Set-Cookie']).to include('eeny_meeny_my_page_v1=')
      end
    end

    context 'and given a smoke test query parameter' do
      let(:request) { Rack::MockRequest.new(subject) }

      before(:example) do
        @response = request.get('/test?smoke_test_id=my_smoke_test', 'CONTENT_TYPE' => 'text/plain')
      end

      it "sets the 'HTTP_COOKIE' header on the request" do
        expect(app['HTTP_COOKIE']).to be
        expect(app['HTTP_COOKIE']).to include('smoke_test_my_smoke_test_v1=')
      end

      it "sets the 'Set-Cookie' header on the response" do
        expect(@response['Set-Cookie']).to be
        expect(@response['Set-Cookie']).to include('smoke_test_my_smoke_test_v1=')
      end
    end
  end

end
