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
  add_group('Rake Tasks', 'lib/tasks')
  add_group('Specs', 'spec')
end

require 'rspec'
require 'yaml'
require 'mock_rack_app'

require 'eeny-meeny'


RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"

  config.before(:each) do
    EenyMeeny.reset! # reset configuration before every test.
  end
  config.before(:each, experiments: true) do
    EenyMeeny.configure do |config|
      config.experiments = YAML.load_file(File.join('spec','fixtures','experiments.yml'))
    end
  end

end
