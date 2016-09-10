require 'rack'
require 'time'
require 'active_support/time'
require 'eeny-meeny/models/experiment'
require 'eeny-meeny/models/encryptor'
require 'eeny-meeny/models/cookie'

module EenyMeeny
  class Middleware

    def initialize(app)
      @app = app
      @experiments = EenyMeeny::Experiment.find_all
      @cookie_config = EenyMeeny.config.cookies
    end

    def call(env)
      request = Rack::Request.new(env)
      cookies = request.cookies
      now = Time.zone.now
      new_cookies = {}
      existing_set_cookie_header = env['Set-Cookie']
      # Prepare for experiments.
      @experiments.each do |experiment|
        # Skip experiments that haven't started yet or if it ended
        next if experiment.start_at && (now < experiment.start_at)
        next if experiment.end_at && (now > experiment.end_at)
        # skip experiments that already have a cookie
        unless cookies.has_key?(EenyMeeny::Cookie.cookie_name(experiment))
          env['Set-Cookie'] = ''
          cookie = EenyMeeny::Cookie.create_for_experiment(experiment, @cookie_config)
          # Set HTTP_COOKIE header to enable experiment on first pageview
          Rack::Utils.set_cookie_header!(env,
                                         cookie.name,
                                         cookie.to_h)
          env['HTTP_COOKIE'] = '' if env['HTTP_COOKIE'].nil?
          env['HTTP_COOKIE'] += '; ' unless env['HTTP_COOKIE'].empty?
          env['HTTP_COOKIE'] += env['Set-Cookie']
          new_cookies[cookie.name] = cookie
        end
      end
      # Clean up 'Set-Cookie' header.
      if existing_set_cookie_header.nil?
        env.delete('Set-Cookie')
      else
        env['Set-Cookie'] = existing_set_cookie_header
      end
      # Delegate to app
      status, headers, body = @app.call(env)
      response = Rack::Response.new(body, status, headers)
      # Add new cookies to 'Set-Cookie' header
      new_cookies.each do |key, value|
        response.set_cookie(key,value.to_h)
      end
      response.finish
    end
  end
end
