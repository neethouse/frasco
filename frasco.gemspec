# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'frasco/version'

Gem::Specification.new do |spec|
  spec.name          = "frasco"
  spec.version       = Frasco::VERSION
  spec.authors       = ["mtmta"]
  spec.email         = ["d.masamoto@covelline.com"]
  spec.description   = %q{Test environment manager for iOS simulator.}
  spec.summary       = spec.description
  spec.homepage      = "http://neethouse.org/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "thor"
end
