# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require "pundit"
require "pundit/rspec"

require "rack"
require "rack/test"
require "pry"
require "active_support"
require "active_support/core_ext"
require "active_model/naming"
require "action_controller/metal/strong_parameters"

# Load all supporting files: models, policies, etc.
require "zeitwerk"
loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path("support/models", __dir__))
loader.push_dir(File.expand_path("support/policies", __dir__))
loader.push_dir(File.expand_path("support/lib", __dir__))
loader.setup
loader.eager_load
