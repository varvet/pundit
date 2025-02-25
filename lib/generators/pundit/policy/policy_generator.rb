# frozen_string_literal: true

module Pundit
  # @private
  module Generators
    # @private
    class PolicyGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_policy
        template "policy.rb.tt", File.join("app/policies", class_path, "#{file_name}_policy.rb")
      end

      hook_for :test_framework
    end
  end
end
