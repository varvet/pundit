# frozen_string_literal: true

module Pundit
  module CacheStore
    # @api private
    class NullStore
      @instance = new

      class << self
        attr_reader :instance
      end

      def fetch(*, **)
        yield
      end
    end
  end
end
