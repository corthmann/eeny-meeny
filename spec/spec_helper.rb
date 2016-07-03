require 'simplecov'
require 'simplecov-rcov'
require 'codeclimate-test-reporter'

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter[
                SimpleCov::Formatter::HTMLFormatter,
                SimpleCov::Formatter::RcovFormatter,
                CodeClimate::TestReporter::Formatter
            ]
  add_group('EenyMeeny', 'lib/eeny-meeny')
  add_group('Specs', 'spec')
end

require 'rspec'
require 'yaml'
require 'eeny-meeny'
require 'mock_rack_app'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"
end
