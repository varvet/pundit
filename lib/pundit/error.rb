# frozen_string_literal: true

module Pundit
  # @api private
  # To avoid name clashes with common Error naming when mixing in Pundit,
  # keep it here with compact class style definition.
  class Error < StandardError; end

  # Error that will be raised when authorization has failed
  class NotAuthorizedError < Error
    # @see #initialize
    attr_reader :query
    # @see #initialize
    attr_reader :record
    # @see #initialize
    attr_reader :policy

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
  class InvalidConstructorError < Error; end

  # Error that will be raised if a controller action has not called the
  # `authorize` or `skip_authorization` methods.
  class AuthorizationNotPerformedError < Error; end

  # Error that will be raised if a controller action has not called the
  # `policy_scope` or `skip_policy_scope` methods.
  class PolicyScopingNotPerformedError < AuthorizationNotPerformedError; end

  # Error that will be raised if a policy or policy scope is not defined.
  class NotDefinedError < Error; end
end
