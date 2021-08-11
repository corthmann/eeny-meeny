# frozen_string_literal: true

require 'simplecov-rcov'

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)
SimpleCov.add_group('Lib', 'lib')
SimpleCov.add_group('Helpers', 'lib/eeny-meeny/helpers')
SimpleCov.add_group('Models', 'lib/eeny-meeny/models')
SimpleCov.add_group('Routing', 'lib/eeny-meeny/routing')
SimpleCov.add_group('Rake Tasks', 'lib/tasks')
SimpleCov.add_group('Specs', 'spec')
SimpleCov.start
