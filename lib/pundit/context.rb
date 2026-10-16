# frozen_string_literal: true

module Pundit
  # {Pundit::Context} is intended to be created once per request and user, and
  # it is then used to perform authorization checks throughout the request.
  #
  # @example Using Sinatra
  #   helpers do
  #     def current_user = ...
  #
  #     def pundit
  #       @pundit ||= Pundit::Context.new(user: current_user)
  #     end
  #   end
  #
  #   get "/posts/:id" do |id|
  #     pundit.authorize(Post.find(id), query: :show?)
  #   end
  #
  # @example Using [Roda](https://roda.jeremyevans.net/index.html)
  #   route do |r|
  #     context = Pundit::Context.new(user:)
  #
  #     r.get "posts", Integer do |id|
  #       context.authorize(Post.find(id), query: :show?)
  #     end
  #   end
  #
  # @since v2.3.2
  class Context
    # @see Pundit::Authorization#pundit
    # @param user later passed to policies and scopes
    # @param policy_cache [#fetch] cache store for policies (see e.g. {CacheStore::NullStore})
    # @param finder [#policy, #scope] finds policy and scope classes
    #   for records (see {Pundit::Finder})
    # @since v2.3.2
    def initialize(user:, policy_cache: CacheStore::NullStore.instance, finder: Finder.new)
      @user = user
      @policy_cache = policy_cache
      @finder = finder
    end

    # @api public
    # @see #initialize
    # @since v2.3.2
    attr_reader :user

    # @api private
    # @see #initialize
    # @since v2.3.2
    attr_reader :policy_cache

    # @api private
    # @see #initialize
    # @since v2.6.0
    attr_reader :finder

    # Returns a context like this one, with the given collaborators swapped.
    #
    # @example Using one policy for all posts in a controller
    #   class Admin::PostsController < ApplicationController
    #     def pundit = super.with(finder: SpecialFinder.new)
    #   end
    #
    # @api public
    # @param (see #initialize)
    # @return [Pundit::Context]
    # @since v2.6.0
    def with(**overrides)
      self.class.new(user: user, policy_cache: policy_cache, finder: finder, **overrides)
    end

    # @!group Policies

    # Retrieves the policy for the given record, initializing it with the
    # record and user and finally throwing an error if the user is not
    # authorized to perform the given action.
    #
    # @param possibly_namespaced_record [Object, Array] the object we're checking permissions of
    # @param query [Symbol, String] the predicate method to check on the policy (e.g. `:show?`)
    # @param policy_class [Class] the policy class we want to force use of
    # @raise [NotAuthorizedError] if the given query method returned false
    # @return [Object] Always returns the passed object record
    # @since v2.3.2
    def authorize(possibly_namespaced_record, query:, policy_class:)
      record = pundit_model(possibly_namespaced_record)
      policy = if policy_class
        policy_class.new(user, record)
      else
        policy!(possibly_namespaced_record)
      end

      raise NotAuthorizedError, query: query, record: record, policy: policy unless policy.public_send(query)

      record
    end

    # Retrieves the policy for the given record.
    #
    # @see https://github.com/varvet/pundit#policies
    # @param record [Object] the object we're retrieving the policy for
    # @raise [InvalidConstructorError] if the policy constructor called incorrectly
    # @return [Object, nil] instance of policy class with query methods
    # @since v2.3.2
    def policy(record)
      cached_find(record) { finder.policy(record) }
    end

    # Retrieves the policy for the given record, or raises if not found.
    #
    # @see https://github.com/varvet/pundit#policies
    # @param record [Object] the object we're retrieving the policy for
    # @raise [NotDefinedError] if the policy cannot be found
    # @raise [InvalidConstructorError] if the policy constructor called incorrectly
    # @return [Object] instance of policy class with query methods
    # @since v2.3.2
    def policy!(record)
      policy(record) or raise NotDefinedError, "unable to find policy for `#{record.inspect}`"
    end

    # @!endgroup

    # @!group Scopes

    # Retrieves the policy scope for the given record.
    #
    # @see https://github.com/varvet/pundit#scopes
    # @param scope [Object] the object we're retrieving the policy scope for
    # @raise [InvalidConstructorError] if the policy constructor called incorrectly
    # @return [Scope{#resolve}, nil] instance of scope class which can resolve to a scope
    # @since v2.3.2
    def policy_scope(scope)
      policy_scope_class = finder.scope(scope)
      return unless policy_scope_class

      begin
        policy_scope = policy_scope_class.new(user, pundit_model(scope))
      rescue ArgumentError
        raise InvalidConstructorError, "Invalid #<#{policy_scope_class}> constructor is called"
      end

      policy_scope.resolve
    end

    # Retrieves the policy scope for the given record. Raises if not found.
    #
    # @see https://github.com/varvet/pundit#scopes
    # @param scope [Object] the object we're retrieving the policy scope for
    # @raise [NotDefinedError] if the policy scope cannot be found
    # @raise [InvalidConstructorError] if the policy constructor called incorrectly
    # @return [Scope{#resolve}] instance of scope class which can resolve to a scope
    # @since v2.3.2
    def policy_scope!(scope)
      policy_scope(scope) or raise NotDefinedError, "unable to find scope for `#{scope.inspect}`"
    end

    # @!endgroup

    private

    # @!group Private Helpers

    # Finds a cached policy for the given record, or yields to find one.
    #
    # @api private
    # @param record [Object] the object we're retrieving the policy for
    # @yield if no policy was cached
    # @yieldreturn [#new(user, model)]
    # @return [Policy, nil] an instantiated policy
    # @raise [InvalidConstructorError] if policy can't be instantated
    # @since v2.3.2
    def cached_find(record)
      policy_cache.fetch(user: user, record: record) do
        klass = yield
        next unless klass

        model = pundit_model(record)

        begin
          klass.new(user, model)
        rescue ArgumentError
          raise InvalidConstructorError, "Invalid #<#{klass}> constructor is called"
        end
      end
    end

    # Given a possibly namespaced record, return the actual record.
    #
    # @api private
    # @since v2.3.2
    def pundit_model(record)
      record.is_a?(Array) ? record.last : record
    end
  end
end
