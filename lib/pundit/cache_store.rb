# frozen_string_literal: true

module Pundit
  # Namespace for cache store implementations.
  #
  # Cache stores are used to cache policy lookups, so you get the same policy
  # instance for the same record.
  module CacheStore
    # @!group Cache Store Interface

    # @!method fetch(user:, record:, &block)
    #   Looks up a stored policy or generate a new one.
    #
    #   @note This is a method template, but the method does not exist in this module.
    #   @param user [Object]  the user that initiated the action
    #   @param record [Object] the object being accessed
    #   @param block [Proc] the block to execute if missing
    #   @return [Object] the policy

    # @!endgroup
  end
end
