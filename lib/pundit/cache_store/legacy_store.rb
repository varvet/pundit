# frozen_string_literal: true

module Pundit
  module CacheStore
    # @api private
    class LegacyStore
      def initialize(hash = {})
        @store = hash
      end

      def fetch(user:, record:)
        _ = user
        @store[record] ||= yield
      end
    end
  end
end
