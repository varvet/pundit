# frozen_string_literal: true

module Project
  module Admin
    class CommentPolicy < BasePolicy
      def update?
        true
      end

      def destroy?
        false
      end
    end
  end
end
