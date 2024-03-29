require File.expand_path('../lib/eeny-meeny/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'eeny-meeny'
  s.version     = EenyMeeny::VERSION.dup
  s.date        = '2021-08-11'
  s.summary     = "A simple split and smoke testing tool for Rails"
  s.authors     = ["Christian Orthmann"]
  s.email       = 'christian.orthmann@gmail.com'
  s.require_path = 'lib'
  s.files       = `git ls-files`.split("\n") - %w(.rvmrc .gitignore)
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n") - %w(.rvmrc .gitignore)
  s.homepage    = 'http://rubygems.org/gems/eeny-meeny'
  s.license     = 'MIT'

  s.add_development_dependency('rake', '~> 13')
  s.add_development_dependency('rspec', '~> 3')
  s.add_development_dependency('simplecov', '~> 0')
  s.add_development_dependency('simplecov-rcov', '~> 0')
  s.add_development_dependency('yard', '>= 0.9.11', '< 1.0.0')
  s.add_development_dependency('rack-test', '~> 1')
  s.add_runtime_dependency('rack', '>= 1.2.1', '< 3')
  s.add_runtime_dependency('activesupport', '>= 3.0.0', '< 6.2.0')
end
