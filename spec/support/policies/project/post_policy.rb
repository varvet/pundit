# frozen_string_literal: true

module Project
  class PostPolicy < BasePolicy
    class Scope < BaseScope
      def resolve
        scope.read
      end
    end

    alias post record
  end
end
