require 'rspec'
require 'yaml'
require 'eeny-meeny'
require 'mock_rack_app'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"
end
