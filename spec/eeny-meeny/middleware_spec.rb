require 'spec_helper'
require 'eeny-meeny/encryptor'
require 'eeny-meeny/middleware'

def initialize_app(secure: true, secret: 'test', path: '/', same_site: :strict)
  experiments = YAML.load_file(File.join('spec','fixtures','experiments.yml'))
  described_class.new(app, experiments, secure, secret, path, same_site)
end

describe EenyMeeny::Middleware do

  let(:app) { MockRackApp.new }
  before(:example) do
    allow(Time).to receive_message_chain(:zone, :now) { Time.now }
  end

  describe 'when initialized' do

    context "with 'config.eeny_meeny.secure = true'" do
      it 'creates an instance of EenyMeeny::Encryptor' do
        instance = initialize_app
        expect(instance.instance_variable_get(:@secure)).to be true
        expect(instance.instance_variable_get(:@encryptor)).to be_a EenyMeeny::Encryptor
      end
    end

    context "with 'config.eeny_meeny.secure = false'" do
      it 'does not have an instance of EenyMeeny::Encryptor' do
        instance = initialize_app(secure: false)
        expect(instance.instance_variable_get(:@secure)).to be false
        expect(instance.instance_variable_get(:@encryptor)).to be nil
      end
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
        @original_request_cookies = 'test=abc;eeny_meeny_my_page_v1=on1tOQ5hiKdA0biVZVwvTUQcmkODacwdpi%2FedQJIYQz9KdWYAXqzCafF5Dqqa6xtHFBdXYVmz%2Bp4%2FigmKz4hBVYZbJU%2FMwBbvYG%2BIoBelk10PxwtyxbA%2BiDzFT4jZeiTkNOmZ3rp1Gzz74JjT4aocqB187p7SrpeM2jfyZ8ZKPOiZs6tXf0QoXkV%2BZbtxJLRPr5lgmGxslfM8vCIm1%2F0HQ%3D%3D;'
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
  end

end
