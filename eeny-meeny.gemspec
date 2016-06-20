require File.expand_path('../lib/eeny-meeny/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'eeny-meeny'
  s.version     = EenyMeeny::VERSION.dup
  s.date        = '2016-06-20'
  s.summary     = "A simple split testing tool for Rails"
  s.description = "A simple split testing tool for Rails"
  s.authors     = ["Christian Orthmann"]
  s.email       = 'christian.orthmann@gmail.com'
  s.require_path = 'lib'
  s.files       = `git ls-files`.split("\n") - %w(.rvmrc .gitignore)
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n") - %w(.rvmrc .gitignore)
  s.homepage    = 'http://rubygems.org/gems/eeny-meeny'
  s.license     = 'MIT'

  s.add_development_dependency('rake', '~> 10')
  s.add_development_dependency('rspec', '~> 3')
  s.add_development_dependency('webmock', '~> 1')
  s.add_development_dependency('simplecov', '~> 0')
  s.add_development_dependency('simplecov-rcov', '~> 0')
  s.add_development_dependency('yard', '~> 0')
  s.add_runtime_dependency('rack')
  s.add_runtime_dependency('activesupport', '>= 3.0.0', '< 5.0.0')
end
