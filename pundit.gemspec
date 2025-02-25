# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pundit/version"

Gem::Specification.new do |gem|
  gem.name          = "pundit"
  gem.version       = Pundit::VERSION
  gem.authors       = ["Jonas Nicklas", "Varvet AB"]
  gem.email         = ["jonas.nicklas@gmail.com", "info@varvet.com"]
  gem.description   = "Object oriented authorization for Rails applications"
  gem.summary       = "OO authorization for Rails"
  gem.homepage      = "https://github.com/varvet/pundit"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.metadata      = {
    "rubygems_mfa_required" => "true",
    "bug_tracker_uri" => "https://github.com/varvet/pundit/issues",
    "changelog_uri" => "https://github.com/varvet/pundit/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://github.com/varvet/pundit/blob/main/README.md",
    "homepage_uri" => "https://github.com/varvet/pundit",
    "source_code_uri" => "https://github.com/varvet/pundit"
  }

  gem.add_dependency "activesupport", ">= 3.0.0"
end
