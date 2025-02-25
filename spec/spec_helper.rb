# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  require "simplecov_json_formatter"
  require_relative "simple_cov_check_action_formatter"
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter,
    SimpleCovCheckActionFormatter.with_options(
      output_filename: "simplecov-check-action.json"
    )
  ])
  SimpleCov.start do
    add_filter "/spec/"
    enable_coverage :branch
    primary_coverage :branch
  end
end

# @see https://github.com/rails/rails/issues/54260
require "logger" if RUBY_ENGINE == "jruby" && RUBY_ENGINE_VERSION.start_with?("9.3")

require "pundit"
require "pundit/rspec"
require "active_model/naming"

# Load all supporting files: models, policies, etc.
require "zeitwerk"
loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path("support/models", __dir__))
loader.push_dir(File.expand_path("support/policies", __dir__))
loader.push_dir(File.expand_path("support/lib", __dir__))
loader.setup
loader.eager_load
