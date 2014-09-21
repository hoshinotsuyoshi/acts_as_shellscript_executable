# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_shellscript_executable/version'

Gem::Specification.new do |spec|
  spec.name          = "acts_as_shellscript_executable"
  spec.version       = ActiveRecord::Acts::ShellscriptExecutable::VERSION
  spec.authors       = ["hoshinotsuyoshi"]
  spec.email         = ["guitarpopnot330@gmail.com"]
  spec.summary       = %q{#execute! executes column's content as shellscript}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "sqlite3"

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency("activerecord", [">= 4.1.6"])
end
