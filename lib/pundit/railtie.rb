# frozen_string_literal: true

require "rails/railtie"

module Pundit
  class Railtie < Rails::Railtie
    generators do |app|
      Rails::Generators.configure! app.config.generators
      templates_dir = File.expand_path("../generators/rails/scaffold_controller/templates", __dir__)
      Rails::Generators::ScaffoldControllerGenerator.source_paths.unshift(templates_dir)
      require "generators/pundit/scaffold/scaffold_generator"
    end
  end
end
