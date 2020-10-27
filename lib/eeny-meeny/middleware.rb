require 'rack'
require 'time'
require 'active_support/time'
require 'eeny-meeny/models/experiment'
require 'eeny-meeny/models/encryptor'
require 'eeny-meeny/models/cookie'

module EenyMeeny
  class Middleware

    # Headers
    HTTP_COOKIE    = 'HTTP_COOKIE'.freeze
    REQUEST_METHOD = 'REQUEST_METHOD'.freeze
    QUERY_STRING   = 'QUERY_STRING'.freeze

    def initialize(app)
      @app = app
      @experiments = EenyMeeny::Experiment.find_all
      @cookie_config = EenyMeeny.config.cookies
    end

    def call(env)
      cookies          = Rack::Utils.parse_query(env[HTTP_COOKIE],';,')  { |s| Rack::Utils.unescape(s) rescue s }
      query_parameters = query_hash(env)
      now              = Time.zone.now
      new_cookies      = {}
      delete_cookies   = find_deprecated_cookies(cookies, now)
      # Prepare for experiments.
      @experiments.each do |experiment|
        # Skip inactive experiments
        next unless experiment.active?(now)
        env, new_cookies = prepare_experiment(env, cookies, new_cookies, query_parameters, experiment)
      end
      # Prepare smoke tests
      env, new_cookies = prepare_smoke_test(env, new_cookies, query_parameters)
      # Delegate to app
      status, headers, body = @app.call(env)
      response = Rack::Response.new(body, status, headers)
      # Add new cookies to 'Set-Cookie' header
      new_cookies.each do |key, value|
        response.set_cookie(key,value.to_h)
      end
      delete_cookies.each do |key, value|
        response.delete_cookie(key, value: value, path: @cookie_config[:path], same_site: @cookie_config[:same_site])
      end
      response.finish
    end

    private

    def find_deprecated_cookies(cookies, now)
      deprecated_cookies = {}
      cookies.each do |cookie_name, value|
        # Skip any cookie that does not have the 'eeny_meeny_' prefix
        next unless cookie_name.to_s.start_with?(EenyMeeny::Cookie::EXPERIMENT_PREFIX)
        # Mark cookies that does not match any existing active experiment as 'deprecated'.
        experiment = EenyMeeny::Experiment.find_by_cookie_name(cookie_name)
        next if experiment && experiment.active?(now)
        deprecated_cookies[cookie_name] = value
      end
      deprecated_cookies
    end

    def prepare_experiment(env, cookies, new_cookies, query_parameters, experiment)
      # Trigger experiment through query parameters
      cookie_name = EenyMeeny::Cookie.cookie_name(experiment)
      has_experiment_trigger = EenyMeeny.config.query_parameters[:experiment] && query_parameters.key?(cookie_name)
      # Skip experiments that already have a cookie
      return env, new_cookies unless has_experiment_trigger || !cookies.key?(cookie_name)
      cookie = if has_experiment_trigger
                 # Trigger experiment variation through query parameter.
                 EenyMeeny::Cookie.create_for_experiment_variation(experiment, query_parameters[cookie_name].to_sym, @cookie_config)
               else
                 EenyMeeny::Cookie.create_for_experiment(experiment, @cookie_config)
               end
      # Set HTTP_COOKIE header to enable experiment on first pageview
      env = add_or_replace_http_cookie(env, cookie)
      new_cookies[cookie.name] = cookie
      return env, new_cookies
    end

    def prepare_smoke_test(env, new_cookies, query_parameters)
      # Skip if the EenyMeeny 'smoke test' query parameters configuration is disabled.
      return env, new_cookies unless EenyMeeny.config.query_parameters[:smoke_test]
      # Skip if no valid 'smoke_test_id' query parameter present
      return env, new_cookies unless query_parameters.key?('smoke_test_id') && (query_parameters['smoke_test_id'] =~ /\A[A-Za-z_]+\z/)
      # Set HTTP_COOKIE header to enable smoke test on first pageview
      cookie = EenyMeeny::Cookie.create_for_smoke_test(query_parameters['smoke_test_id'], **@cookie_config)
      env = add_or_replace_http_cookie(env, cookie)
      new_cookies[cookie.name] = cookie
      return env, new_cookies
    end

    def query_hash(env)
      # Query Params are only relevant if EenyMeeny.config have them enabled.
      return {} unless EenyMeeny.config.query_parameters[:experiment] || EenyMeeny.config.query_parameters[:smoke_test]
      # Query Params are only relevant to HTTP GET requests.
      return {} unless env[REQUEST_METHOD] == 'GET'
      Rack::Utils.parse_query(env[QUERY_STRING], '&;')
    end

    def add_or_replace_http_cookie(env, cookie)
      cookie_name_escaped = Rack::Utils.escape(cookie.name)
      cookie_string = "#{cookie_name_escaped}=#{Rack::Utils.escape(cookie.value)}"
      env[HTTP_COOKIE] = '' if env[HTTP_COOKIE].nil?
      return env if env[HTTP_COOKIE].sub!(/#{Regexp.escape(cookie_name_escaped)}=[^;]+/, cookie_string)
      env[HTTP_COOKIE] += '; ' unless env[HTTP_COOKIE].empty?
      env[HTTP_COOKIE] += cookie_string
      env
    end
  end
end
