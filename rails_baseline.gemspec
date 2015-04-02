# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_baseline/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_baseline"
  spec.version       = RailsBaseline::VERSION
  spec.authors       = ["Yoon Wai Yan"]
  spec.email         = ["waiyan@cloudcoder.com.my"]
  spec.summary       = %q{Rails 4.2 template}
  spec.description   = %q{Create baseline rails app with ease. Based on the normal practices by Cloud Coder team.}
  spec.homepage      = "https://github.com/cloudcodermy/baseline"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "thor"
  spec.add_dependency "rails", "~> 4.2.0"
  spec.add_dependency "rspec"
end
