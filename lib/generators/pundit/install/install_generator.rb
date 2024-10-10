# frozen_string_literal: true

module Pundit
  # @private
  module Generators
    # @private
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_application_policy
        template "application_policy.rb.tt", "app/policies/application_policy.rb"
      end
    end
  end
end
