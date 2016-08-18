# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as/version'

Gem::Specification.new do |spec|
  spec.name          = "acts_as"
  spec.version       = ActsAs::VERSION
  spec.authors       = ["Hired, Inc", "Winfred Nadeau"]
  spec.email         = ["winfred@hired.com", "opensource@hired.com"]
  spec.description   = %q{ActiveRecord extension for easy STI Delegation}
  spec.summary       = %q{ delegate an entire 1:1 association worth of active record field-related helpers }
  spec.homepage      = "http://github.com/wnadeau/acts_as"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '< 2.99'
  spec.add_development_dependency 'sqlite3'

  spec.add_dependency 'activerecord', '< 4.3'
end
