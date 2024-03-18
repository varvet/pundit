# frozen_string_literal: true

require "rails/generators/rails/scaffold/scaffold_generator"

module Rails
  module Generators
    class ScaffoldGenerator
      hook_for :policy, in: :pundit, type: :boolean, default: true
    end
  end
end
