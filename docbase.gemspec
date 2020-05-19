lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docbase/version'

Gem::Specification.new do |spec|
  spec.name          = 'docbase'
  spec.version       = DocBase::VERSION
  spec.authors       = ['ttakuru88']
  spec.email         = ['asaumi+docbase-ruby@kray.jp']

  spec.summary       = 'DocBase API Client, written in Ruby'
  spec.description   = 'DocBase API Client, written in Ruby'
  spec.homepage      = 'https://github.com/krayinc/docbase-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 0.15.2'
  spec.add_dependency 'faraday_middleware', '>= 0.12.2'
end
