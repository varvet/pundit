# frozen_string_literal: true

# @private
module TestUnit
  # @private
  module Generators
    # @private
    class PolicyGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_policy_test
        template "policy_test.rb.tt", File.join("test/policies", class_path, "#{file_name}_policy_test.rb")
      end
    end
  end
end
