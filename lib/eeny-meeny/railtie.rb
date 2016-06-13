require 'eeny-meeny/experiment_helper'
require 'eeny-meeny/middleware'

module EenyMeeny
  class Railtie < Rails::Railtie
    config.eeny_meeny = ActiveSupport::OrderedOptions.new

    initializer 'eeny_meeny.initialize' do |app|
      config.eeny_meeny.experiments ||= [] # experiements need to be loaded from config... yaml is a good idea?
      config.eeny_meeny.secure ||= true
      config.eeny_meeny.secret ||= '9fc8b966eca7d03d55df40c01c10b8e02bf1f9d12d27b8968d53eb53e8c239902d00bf6afae5e726ce1111159eeb2f8f0e77233405db1d82dd71397f651a0a4f'

      ActionController::Base.send :include, EenyMeeny::ExperimentHelper
      ActionView::Base.send :include, EenyMeeny::ExperimentHelper

      app.middleware.insert_before 'ActionDispatch::Cookies', EenyMeeny::Middleware,
                                   config.eeny_meeny.experiments,
                                   config.eeny_meeny.secure,
                                   config.eeny_meeny.secret
    end
  end
end
