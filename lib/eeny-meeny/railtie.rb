require 'eeny-meeny'
require 'eeny-meeny/middleware'
require 'eeny-meeny/helpers/experiment_helper'

module EenyMeeny
  class Railtie < Rails::Railtie
    config.eeny_meeny = ActiveSupport::OrderedOptions.new

    initializer 'eeny_meeny.configure' do |app|
      # Configrue EenyMeeny (defaults set in eeny_meeny.rb)
      EenyMeeny.configure do |config|
        config.cookies               = app.config.eeny_meeny[:cookies]          if app.config.eeny_meeny.key?(:cookies)
        config.experiments           = app.config.eeny_meeny[:experiments]      if app.config.eeny_meeny.key?(:experiments)
        config.secret                = app.config.eeny_meeny[:secret]           if app.config.eeny_meeny.key?(:secret)
        config.secure                = app.config.eeny_meeny[:secure]           if app.config.eeny_meeny.key?(:secure)
        config.query_parameters      = app.config.eeny_meeny[:query_parameters] if app.config.eeny_meeny.key?(:query_parameters)
      end
      # Insert Middleware
      app.middleware.insert_before ActionDispatch::Cookies, EenyMeeny::Middleware
    end

    config.to_prepare do
      # Include Helpers in ActionController and ActionView
      ActiveSupport.on_load(:action_controller_base) do
        include EenyMeeny::ExperimentHelper
      end
    end

    rake_tasks do
      load 'tasks/cookie.rake'
    end
  end
end
