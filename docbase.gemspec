lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docbase/version'

Gem::Specification.new do |spec|
  spec.name          = 'docbase'
  spec.version       = DocBase::VERSION
  spec.authors       = ['danny']
  spec.email         = ['danny@kray.jp']

  spec.summary       = 'DocBase API Client, written in Ruby'
  spec.description   = 'DocBase API Client, written in Ruby'
  spec.homepage      = 'https://github.com/krayinc/docbase-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.9.2'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.10.0'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
end
