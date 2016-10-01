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
        # Skip inactive experiments
        next unless experiment.active?(now)
        # Trigger experiment through query parmeters
        cookie_name = EenyMeeny::Cookie.cookie_name(experiment)
        has_experiment_trigger = EenyMeeny.config.query_parameters[:experiment] && request.params.has_key?(cookie_name)
        # skip experiments that already have a cookie
        if has_experiment_trigger || !cookies.has_key?(cookie_name)
          cookie = if has_experiment_trigger
                     # Trigger experiment variation through query parameter.
                     EenyMeeny::Cookie.create_for_experiment_variation(experiment, request.params[cookie_name].to_sym, @cookie_config)
                   else
                     EenyMeeny::Cookie.create_for_experiment(experiment, @cookie_config)
                   end
          # Set HTTP_COOKIE header to enable experiment on first pageview
          env = add_http_cookie(env, cookie, prepend: has_experiment_trigger)
          new_cookies[cookie.name] = cookie
        end
      end
      # Prepare smoke tests (if enabled through query parameters)
      if EenyMeeny.config.query_parameters[:smoke_test]
        if request.params.has_key?('smoke_test_id') && (request.params['smoke_test_id'] =~ /[A-Za-z_]+/)
          # Set HTTP_COOKIE header to enable smoke test on first pageview
          cookie = EenyMeeny::Cookie.create_for_smoke_test(request.params['smoke_test_id'])
          env = add_http_cookie(env, cookie, prepend: true)
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

    private
    def add_http_cookie(env, cookie, prepend: false)
      env['Set-Cookie'] = ''
      Rack::Utils.set_cookie_header!(env,
                                     cookie.name,
                                     cookie.to_h)
      env['HTTP_COOKIE'] = '' if env['HTTP_COOKIE'].nil?
      if prepend
        # Prepend cookie to the 'HTTP_COOKIE' header. This ensures it overwrites existing cookies when present.
        env['HTTP_COOKIE'] = env['Set-Cookie'] + '; ' + env['HTTP_COOKIE']
      else
        env['HTTP_COOKIE'] += '; ' unless env['HTTP_COOKIE'].empty?
        env['HTTP_COOKIE'] += env['Set-Cookie']
      end
      env
    end
  end
end
