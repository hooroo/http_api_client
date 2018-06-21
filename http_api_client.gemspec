# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http_api_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'http_api_client'
  spec.version       = HttpApiClient::VERSION
  spec.authors       = ['Rob Monie', 'Andrei Miulescu', 'Stuart Liston', 'Chris Rode']
  spec.email         = ['robmonie@gmail.com']
  spec.description   = %q{Http client wrapper for simplified api access}
  spec.summary       = %q{}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'pry-byebug', '~> 3.3.0'

  spec.add_dependency 'activesupport', '>= 3.1'
  spec.add_dependency 'faraday', '>= 0.8.9'
  # spec.add_dependency 'net-http-persistent', '~> 2.9'
  spec.add_dependency 'oj', '~> 3.6'

end
