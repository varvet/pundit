# frozen_string_literal: true

require "active_support"

require "pundit/version"
require "pundit/policy_finder"
require "pundit/authorization"
require "pundit/context"
require "pundit/cache_store"
require "pundit/cache_store/null_store"
require "pundit/cache_store/legacy_store"
require "pundit/railtie" if defined?(Rails)

# @api private
# To avoid name clashes with common Error naming when mixing in Pundit,
# keep it here with compact class style definition.
class Pundit::Error < StandardError; end # rubocop:disable Style/ClassAndModuleChildren

# Hello? Yes, this is Pundit.
#
# @api public
module Pundit
  # @api private
  # @deprecated See {Pundit::PolicyFinder}
  SUFFIX = Pundit::PolicyFinder::SUFFIX

  # @api private
  # @private
  module Generators; end

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

  def self.included(base)
    location = caller_locations(1, 1).first
    warn <<~WARNING
      'include Pundit' is deprecated. Please use 'include Pundit::Authorization' instead.
       (called from #{location.label} at #{location.path}:#{location.lineno})
    WARNING
    base.include Authorization
  end

  class << self
    # @see Pundit::Context#authorize
    def authorize(user, record, query, policy_class: nil, cache: nil)
      context = if cache
        policy_cache = CacheStore::LegacyStore.new(cache)
        Context.new(user: user, policy_cache: policy_cache)
      else
        Context.new(user: user)
      end

      context.authorize(record, query: query, policy_class: policy_class)
    end

    # @see Pundit::Context#policy_scope
    def policy_scope(user, *args, **kwargs, &block)
      Context.new(user: user).policy_scope(*args, **kwargs, &block)
    end

    # @see Pundit::Context#policy_scope!
    def policy_scope!(user, *args, **kwargs, &block)
      Context.new(user: user).policy_scope!(*args, **kwargs, &block)
    end

    # @see Pundit::Context#policy
    def policy(user, *args, **kwargs, &block)
      Context.new(user: user).policy(*args, **kwargs, &block)
    end

    # @see Pundit::Context#policy!
    def policy!(user, *args, **kwargs, &block)
      Context.new(user: user).policy!(*args, **kwargs, &block)
    end
  end

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
