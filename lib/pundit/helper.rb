# frozen_string_literal: true

module Pundit
  # Rails view helpers, to allow a slightly different view-specific
  # implementation of the methods in {Pundit::Authorization}.
  #
  # @api private
  # @since v1.0.0
  module Helper
    # @see Pundit::Authorization#pundit_policy_scope
    # @since v1.0.0
    def policy_scope(scope)
      pundit_policy_scope(scope)
    end
  end
end
