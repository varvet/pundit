# frozen_string_literal: true

module Pundit
  module CacheStore
    # A cache store that does not cache anything.
    #
    # Use `NullStore.instance` to get the singleton instance, it is thread-safe.
    #
    # @see Pundit::Context#initialize
    # @api private
    class NullStore
      @instance = new

      class << self
        # @return [NullStore] the singleton instance
        attr_reader :instance
      end

      # Always yields, does not cache anything.
      # @yield
      # @return [any] whatever the block returns.
      def fetch(*, **)
        yield
      end
    end
  end
end
