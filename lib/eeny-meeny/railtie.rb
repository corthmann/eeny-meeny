require 'eeny-meeny'
require 'eeny-meeny/experiment_helper'
require 'eeny-meeny/middleware'

module EenyMeeny
  class Railtie < Rails::Railtie
    config.eeny_meeny = ActiveSupport::OrderedOptions.new

    initializer 'eeny_meeny.configure' do |app|
      # Configrue EenyMeeny (defaults set in eeny_meeny.rb)
      EenyMeeny.configure do |config|
        config.cookies     = app.config.eeny_meeny[:cookies]     if app.config.eeny_meeny.has_key?(:cookies)
        config.experiments = app.config.eeny_meeny[:experiments] if app.config.eeny_meeny.has_key?(:experiments)
        config.secret      = app.config.eeny_meeny[:secret]      if app.config.eeny_meeny.has_key?(:secret)
        config.secure      = app.config.eeny_meeny[:secure]      if app.config.eeny_meeny.has_key?(:secure)
      end
      # Include Helpers in ActionController and ActionView
      ActionController::Base.send :include, EenyMeeny::ExperimentHelper
      ActionView::Base.send :include, EenyMeeny::ExperimentHelper
      # Insert Middleware
      app.middleware.insert_before 'ActionDispatch::Cookies', EenyMeeny::Middleware
    end

    rake_tasks do
      load 'tasks/cookie.rake'
    end
  end
end
