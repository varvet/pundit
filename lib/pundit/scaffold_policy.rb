# frozen_string_literal: true

module Pundit
  # Makes `rails generate scaffold` and `rails generate scaffold_controller` also generate a policy.
  #
  # Only the policy (and its test, via the policy generator) is generated; the scaffolded controller is left untouched.
  #
  # @private
  module ScaffoldPolicy
    def self.install
      require "rails/generators"
      require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"

      Rails::Generators::ScaffoldControllerGenerator.class_eval do
        class_option :policy, type: :boolean, default: true, desc: "Generate a Pundit policy"

        def create_pundit_policy
          invoke "pundit:policy", [name] if options[:policy]
        end
      end
    end
  end
end
