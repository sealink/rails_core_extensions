Gem::Specification.new do |spec|
  spec.name          = 'rails_core_extensions'
  spec.version       = '0.0.1'
  spec.authors       = ['Michael Noack', 'Allesandro Berardi']
  spec.email         = ['support@travellink.com.au']
  spec.description   = %q{Set of extensions to core rails libraries.}
  spec.summary       = %q{Set of extensions to core rails libraries.}
  spec.homepage      = 'http://github.com/sealink/rails_core_extensions'

  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency('activerecord', ['>= 2.3.0', '< 5.0.0'])
  spec.add_dependency('actionpack', ['>= 2.3.0', '< 5.0.0'])
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'activerecord-nulldb-adapter'
end
