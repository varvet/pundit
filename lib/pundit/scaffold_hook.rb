# frozen_string_literal: true

module Pundit
  module ScaffoldHook
    def self.install
      return if @installed

      @installed = true

      require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"

      Rails::Generators::ScaffoldControllerGenerator.class_eval do
        class_option :policy, type: :boolean, default: true, desc: "Generate a Pundit policy"

        def generate_pundit_policy
          return unless options[:policy]
          invoke "pundit:policy"
        end
      end
    end
  end
end
