# frozen_string_literal: true

module Project
  class CommentPolicy < BasePolicy
    class Scope < BaseScope
      def resolve
        scope
      end
    end

    def update?
      true
    end

    alias_method :comment, :record
  end
end
