# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_core_extensions/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails_core_extensions'
  spec.version       = RailsCoreExtensions::VERSION
  spec.authors       = ['Michael Noack', 'Alessandro Berardi']
  spec.email         = ['support@travellink.com.au']
  spec.description   = %q{Set of extensions to core rails libraries.}
  spec.summary       = %q{Set of extensions to core rails libraries.}
  spec.homepage      = 'http://github.com/sealink/rails_core_extensions'

  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.0'

  spec.add_dependency 'activerecord', ['>= 6.0.0']
  spec.add_dependency 'actionpack', ['>= 6.0.0']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'activerecord-nulldb-adapter'
  spec.add_development_dependency 'coverage-kit'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sqlite3'
end
