# frozen_string_literal: true

module Pundit
  module CacheStore
    # A cache store that uses only the record as a cache key, and ignores the user.
    #
    # The original cache mechanism used by Pundit.
    #
    # @api private
    class LegacyStore
      def initialize(hash = {})
        @store = hash
      end

      # A cache store that uses only the record as a cache key, and ignores the user.
      #
      # @note `nil` results are not cached.
      def fetch(user:, record:)
        _ = user
        @store[record] ||= yield
      end
    end
  end
end
