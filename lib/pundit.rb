# frozen_string_literal: true

require "active_support"

require "pundit/version"
require "pundit/error"
require "pundit/policy_finder"
require "pundit/context"
require "pundit/authorization"
require "pundit/helper"
require "pundit/cache_store"
require "pundit/cache_store/null_store"
require "pundit/cache_store/legacy_store"
require "pundit/railtie" if defined?(Rails)

# Hello? Yes, this is Pundit.
#
# @api public
module Pundit
  # @api private
  # @since v1.0.0
  # @deprecated See {Pundit::PolicyFinder}
  SUFFIX = Pundit::PolicyFinder::SUFFIX

  # @api private
  # @private
  # @since v0.1.0
  module Generators; end

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
    # @since v1.0.0
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
    # @since v0.1.0
    def policy_scope(user, *args, **kwargs, &block)
      Context.new(user: user).policy_scope(*args, **kwargs, &block)
    end

    # @see Pundit::Context#policy_scope!
    # @since v0.1.0
    def policy_scope!(user, *args, **kwargs, &block)
      Context.new(user: user).policy_scope!(*args, **kwargs, &block)
    end

    # @see Pundit::Context#policy
    # @since v0.1.0
    def policy(user, *args, **kwargs, &block)
      Context.new(user: user).policy(*args, **kwargs, &block)
    end

    # @see Pundit::Context#policy!
    # @since v0.1.0
    def policy!(user, *args, **kwargs, &block)
      Context.new(user: user).policy!(*args, **kwargs, &block)
    end
  end
end
