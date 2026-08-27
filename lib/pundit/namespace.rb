# frozen_string_literal: true

module Pundit
  # Wraps every record in a namespace before its policy or scope is looked up.
  #
  # An empty namespace leaves records alone.
  #
  # @example
  #   namespace = Pundit::Namespace.new(:admin)
  #   namespace.wrap(post)             # => [:admin, post]
  #   namespace.wrap([:reports, post]) # => [:admin, :reports, post]
  #
  # @see Pundit::Context#with_namespace
  # @since v2.6.0
  class Namespace
    # @param namespace [Array<Symbol>]
    # @since v2.6.0
    def initialize(*namespace)
      @namespace = namespace
    end

    # @see #initialize
    # @since v2.6.0
    attr_reader :namespace

    # @param record [Object, Array] a possibly already namespaced record
    # @return [Object, Array] the record under this namespace
    # @since v2.6.0
    def wrap(record)
      return record if namespace.empty?

      record.is_a?(Array) ? [*namespace, *record] : [*namespace, record]
    end

    # @param (see #initialize)
    # @return [Namespace] a new namespace, replacing this one
    # @since v2.6.0
    def for(...)
      self.class.new(...)
    end
  end
end
