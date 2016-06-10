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
      status, headers, body = @app.call(env)
      request = Rack::Request.new(env)
      cookies = request.cookies
      response = Rack::Response.new(body, status, headers)
      now = Time.zone.now
      # cookies = Rack::Utils.parse_cookies
      @experiments.each do |experiment|
        # Skip experiments that haven't started yet or if it ended
        next if experiment.start_at && (now < experiment.start_at)
        next if experiment.end_at && (now > experiment.end_at)
        # skip experiments that already have a cookie
        next if has_experiment_cookie?(cookies, experiment)
        # write experiment cookie for 'new experiments'
        write_experiment_cookie(response, experiment)
      end
      #TODO: clean up old experiment cookies ? (might not be needed with expires = experiment.end_at)
      response.finish # finish writes out the response in the expected format.
    end
  end
end
