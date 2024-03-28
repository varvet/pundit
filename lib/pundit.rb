# frozen_string_literal: true

require "pundit/version"
require "pundit/policy_finder"
require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/introspection"
require "active_support/dependencies/autoload"
require "pundit/authorization"
require "pundit/context"
require "pundit/cache_store/null_store"
require "pundit/cache_store/legacy_store"

# @api private
# To avoid name clashes with common Error naming when mixing in Pundit,
# keep it here with compact class style definition.
class Pundit::Error < StandardError; end # rubocop:disable Style/ClassAndModuleChildren

# @api public
module Pundit
  SUFFIX = "Policy"

  # @api private
  module Generators; end

  # Error that will be raised when authorization has failed
  class NotAuthorizedError < Error
    attr_reader :query, :record, :policy

    def initialize(options = {})
      if options.is_a? String
        message = options
      else
        @query  = options[:query]
        @record = options[:record]
        @policy = options[:policy]

        message = options.fetch(:message) { "not allowed to #{query} this #{record.class}" }
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
    # @see [Pundit::Context#authorize]
    def authorize(user, record, query, policy_class: nil, cache: nil)
      context = if cache
        Context.new(user: user, policy_cache: cache)
      else
        Context.new(user: user)
      end

      context.authorize(record, query: query, policy_class: policy_class)
    end

    # @see [Pundit::Context#policy_scope]
    def policy_scope(user, *args, **kwargs, &block)
      Context.new(user: user).policy_scope(*args, **kwargs, &block)
    end

    # @see [Pundit::Context#policy_scope!]
    def policy_scope!(user, *args, **kwargs, &block)
      Context.new(user: user).policy_scope!(*args, **kwargs, &block)
    end

    # @see [Pundit::Context#policy]
    def policy(user, *args, **kwargs, &block)
      Context.new(user: user).policy(*args, **kwargs, &block)
    end

    # @see [Pundit::Context#policy!]
    def policy!(user, *args, **kwargs, &block)
      Context.new(user: user).policy!(*args, **kwargs, &block)
    end
  end

  # @api private
  module Helper
    def policy_scope(scope)
      pundit_policy_scope(scope)
    end
  end
end
