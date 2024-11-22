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
  class Context
    # @see Pundit::Authorization#pundit
    # @param user later passed to policies and scopes
    # @param policy_cache [#fetch] cache store for policies (see e.g. {CacheStore::NullStore})
    def initialize(user:, policy_cache: CacheStore::NullStore.instance)
      @user = user
      @policy_cache = policy_cache
    end

    # @api public
    # @see #initialize
    attr_reader :user

    # @api private
    # @see #initialize
    attr_reader :policy_cache

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
    def policy(record)
      cached_find(record, &:policy)
    end

    # Retrieves the policy for the given record, or raises if not found.
    #
    # @see https://github.com/varvet/pundit#policies
    # @param record [Object] the object we're retrieving the policy for
    # @raise [NotDefinedError] if the policy cannot be found
    # @raise [InvalidConstructorError] if the policy constructor called incorrectly
    # @return [Object] instance of policy class with query methods
    def policy!(record)
      cached_find(record, &:policy!)
    end

    # @!endgroup

    # @!group Scopes

    # Retrieves the policy scope for the given record.
    #
    # @see https://github.com/varvet/pundit#scopes
    # @param scope [Object] the object we're retrieving the policy scope for
    # @raise [InvalidConstructorError] if the policy constructor called incorrectly
    # @return [Scope{#resolve}, nil] instance of scope class which can resolve to a scope
    def policy_scope(scope)
      policy_scope_class = policy_finder(scope).scope
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
    def policy_scope!(scope)
      policy_scope_class = policy_finder(scope).scope!

      begin
        policy_scope = policy_scope_class.new(user, pundit_model(scope))
      rescue ArgumentError
        raise InvalidConstructorError, "Invalid #<#{policy_scope_class}> constructor is called"
      end

      policy_scope.resolve
    end

    # @!endgroup

    private

    # @!group Private Helpers

    # Finds a cached policy for the given record, or yields to find one.
    #
    # @api private
    # @param record [Object] the object we're retrieving the policy for
    # @yield a policy finder if no policy was cached
    # @yieldparam [PolicyFinder] policy_finder
    # @yieldreturn [#new(user, model)]
    # @return [Policy, nil] an instantiated policy
    # @raise [InvalidConstructorError] if policy can't be instantated
    def cached_find(record)
      policy_cache.fetch(user: user, record: record) do
        klass = yield policy_finder(record)
        next unless klass

        model = pundit_model(record)

        begin
          klass.new(user, model)
        rescue ArgumentError
          raise InvalidConstructorError, "Invalid #<#{klass}> constructor is called"
        end
      end
    end

    # Return a policy finder for the given record.
    #
    # @api private
    # @return [PolicyFinder]
    def policy_finder(record)
      PolicyFinder.new(record)
    end

    # Given a possibly namespaced record, return the actual record.
    #
    # @api private
    def pundit_model(record)
      record.is_a?(Array) ? record.last : record
    end
  end
end
