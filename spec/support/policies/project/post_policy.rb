# frozen_string_literal: true

module Project
  class PostPolicy < BasePolicy
    class Scope < BaseScope
      def resolve
        scope.read
      end
    end

    alias_method :post, :record
  end
end
