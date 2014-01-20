# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'places_http/version'

Gem::Specification.new do |spec|
  spec.name          = "places_http"
  spec.version       = PlacesHttp::VERSION
  spec.authors       = ["Rob Monie"]
  spec.email         = ["robmonie@gmail.com"]
  spec.description   = %q{Http related utils and error translation for Hooroo Places applications}
  spec.summary       = %q{Http related utils and error translation for Hooroo Places applications}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_dependency "activesupport"
  spec.add_dependency 'faraday'
  spec.add_dependency 'oj'


end
