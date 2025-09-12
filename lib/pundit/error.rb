# frozen_string_literal: true

module Pundit
  # @api private
  # @since v1.0.0
  # To avoid name clashes with common Error naming when mixing in Pundit,
  # keep it here with compact class style definition.
  class Error < StandardError; end

  # Error that will be raised when authorization has failed
  # @since v0.1.0
  class NotAuthorizedError < Error
    # @see #initialize
    # @since v0.2.3
    attr_reader :query
    # @see #initialize
    # @since v0.2.3
    attr_reader :record
    # @see #initialize
    # @since v0.2.3
    attr_reader :policy

    # @since v1.0.0
    #
    # @overload initialize(message)
    #   Create an error with a simple error message.
    #   @param [String] message A simple error message string.
    #
    # @overload initialize(options)
    #   Create an error with the specified attributes.
    #   @param [Hash] options The error options.
    #   @option options [String] :message Optional custom error message. Will default to a generalized message.
    #   @option options [Symbol] :query The name of the policy method that was checked.
    #   @option options [Object] :record The object that was being checked with the policy.
    #   @option options [Class] :policy The class of policy that was used for the check.
    def initialize(options = {})
      if options.is_a? String
        message = options
      else
        @query  = options[:query]
        @record = options[:record]
        @policy = options[:policy]

        message = options.fetch(:message) do
          record_name = record.is_a?(Class) ? record.to_s : "this #{record.class}"
          "not allowed to #{policy.class}##{query} #{record_name}"
        end
      end

      super(message)
    end
  end

  # Error that will be raised if a policy or policy scope constructor is not called correctly.
  # @since v2.0.0
  class InvalidConstructorError < Error; end

  # Error that will be raised if a controller action has not called the
  # `authorize` or `skip_authorization` methods.
  # @since v0.2.3
  class AuthorizationNotPerformedError < Error; end

  # Error that will be raised if a controller action has not called the
  # `policy_scope` or `skip_policy_scope` methods.
  # @since v0.3.0
  class PolicyScopingNotPerformedError < AuthorizationNotPerformedError; end

  # Error that will be raised if a policy or policy scope is not defined.
  # @since v0.1.0
  class NotDefinedError < Error; end
end
