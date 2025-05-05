# frozen_string_literal: true

module Pundit
  # Rails view helpers, to allow a slightly different view-specific
  # implementation of the methods in {Pundit::Authorization}.
  #
  # @api private
  module Helper
    # @see Pundit::Authorization#pundit_policy_scope
    def policy_scope(scope)
      pundit_policy_scope(scope)
    end
  end
end
