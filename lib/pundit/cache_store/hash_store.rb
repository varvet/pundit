# frozen_string_literal: true

module Pundit
  module CacheStore
    # @api private
    class HashStore
      def initialize(hash = {})
        @store = hash
      end

      def fetch(key)
        @store[key] ||= yield
      end
    end
  end
end
