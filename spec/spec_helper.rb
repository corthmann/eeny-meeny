require 'simplecov'
require 'active_support/time'
require 'rspec'
require 'yaml'
require 'mock_rack_app'
require 'eeny-meeny'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"
  config.expose_dsl_globally = true

  config.before(:suite) do
    Time.zone = 'UTC'
  end

  config.before(:each) do
    EenyMeeny.reset! # reset configuration before every test.
  end
  config.before(:each, experiments: true) do
    EenyMeeny.configure do |config|
      config.experiments = YAML.load_file(File.join('spec','fixtures','experiments.yml'))
    end
  end
  config.before(:each, empty_experiments: true) do
    EenyMeeny.configure do |config|
      config.experiments = YAML.load_file(File.join('spec','fixtures','empty_experiments.yml'))
    end
  end
end
