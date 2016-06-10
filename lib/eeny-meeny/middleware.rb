require 'rack'
require 'time'
require 'eeny-meeny/middleware_helper'
require 'eeny-meeny/experiment'

module EenyMeeny
  class Middleware
    include EenyMeeny::MiddlewareHelper

    def initialize(app, experiments)
      @app = app
      @experiments = experiments.map do |id, experiment|
        EenyMeeny::Experiment.new(id, **experiment)
      end
    end

    def call(env)
      request = Rack::Request.new(env)
      cookies = request.cookies
      now = Time.zone.now
      new_cookies = {}
      # Prepare for experiments.
      @experiments.each do |experiment|
        # Skip experiments that haven't started yet or if it ended
        next if experiment.start_at && (now < experiment.start_at)
        next if experiment.end_at && (now > experiment.end_at)
        # skip experiments that already have a cookie
        unless has_experiment_cookie?(cookies, experiment)
          cookie_value = generate_cookie_value(experiment)
          # Set HTTP_COOKIE header to enable experiment on first pageview
          Rack::Utils.set_cookie_header!(env,
                                         experiment_cookie_name(experiment),
                                         cookie_value)
          env['HTTP_COOKIE'] += '; ' unless env['HTTP_COOKIE'].empty?
          env['HTTP_COOKIE'] += env['Set-Cookie']
          new_cookies[experiment_cookie_name(experiment)] = cookie_value
          # Clean up 'Set-Cookie' header.
          env.delete('Set-Cookie')
        end
      end
      # Delegate to app
      status, headers, body = @app.call(env)
      response = Rack::Response.new(body, status, headers)
      # Add new cookies to 'Set-Cookie' header
      new_cookies.each do |key, value|
        response.set_cookie(key,value)
      end
      response.finish
    end
  end
end
