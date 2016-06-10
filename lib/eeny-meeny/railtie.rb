require 'eeny-meeny/experiment_helper'
require 'eeny-meeny/middleware'

module EenyMeeny
  class Railtie < Rails::Railtie
    config.eeny_meeny = ActiveSupport::OrderedOptions.new

    initializer 'eeny_meeny.initialize' do |app|
      config.eeny_meeny.experiments ||= [] # experiements need to be loaded from config... yaml is a good idea?

      ActionController::Base.send :include, EenyMeeny::ExperimentHelper
      ActionView::Base.send :include, EenyMeeny::ExperimentHelper

      app.middleware.insert_after 'ActionDispatch::Cookies', EenyMeeny::Middleware, config.eeny_meeny.experiments
    end
  end
end
