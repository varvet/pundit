# frozen_string_literal: true

module Pundit
  class Railtie < Rails::Railtie
    if Rails.version.to_f >= 8.0
      initializer "pundit.stats_directories" do
        require "rails/code_statistics"

        if Rails.root.join("app/policies").directory?
          Rails::CodeStatistics.register_directory("Policies", "app/policies")
        end

        if Rails.root.join("test/policies").directory?
          Rails::CodeStatistics.register_directory("Policy tests", "test/policies", test_directory: true)
        end
      end
    end
  end
end
