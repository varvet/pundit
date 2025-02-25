# frozen_string_literal: true

module Pundit
  # Pundit DSL to include in your controllers to provide authorization helpers.
  #
  # @example
  #   class ApplicationController < ActionController::Base
  #     include Pundit::Authorization
  #   end
  # @see #pundit
  # @api public
  module Authorization
    extend ActiveSupport::Concern

    included do
      helper Helper if respond_to?(:helper)
      if respond_to?(:helper_method)
        helper_method :policy
        helper_method :pundit_policy_scope
        helper_method :pundit_user
      end
    end

    protected

    # An instance of {Pundit::Context} initialized with the current user.
    #
    # @note this method is memoized and will return the same instance during the request.
    # @api public
    # @return [Pundit::Context]
    # @see #pundit_user
    # @see #policies
    def pundit
      @pundit ||= Pundit::Context.new(
        user: pundit_user,
        policy_cache: Pundit::CacheStore::LegacyStore.new(policies)
      )
    end

    # Hook method which allows customizing which user is passed to policies and
    # scopes initialized by {#authorize}, {#policy} and {#policy_scope}.
    #
    # @note Make sure to call `pundit_reset!` if this changes during a request.
    # @see https://github.com/varvet/pundit#customize-pundit-user
    # @see #pundit
    # @see #pundit_reset!
    # @return [Object] the user object to be used with pundit
    def pundit_user
      current_user
    end

    # Clears the cached Pundit authorization data.
    #
    # This method should be called when the pundit_user is changed,
    # such as during user switching, to ensure that stale authorization
    # data is not used. Pundit caches authorization policies and scopes
    # for the pundit_user, so calling this method will reset those
    # caches and ensure that the next authorization checks are performed
    # with the correct context for the new pundit_user.
    #
    # @return [void]
    def pundit_reset!
      @pundit = nil
      @_pundit_policies = nil
      @_pundit_policy_scopes = nil
      @_pundit_policy_authorized = nil
      @_pundit_policy_scoped = nil
    end

    # @!group Policies

    # Retrieves the policy for the given record, initializing it with the record
    # and current user and finally throwing an error if the user is not
    # authorized to perform the given action.
    #
    # @param record [Object, Array] the object we're checking permissions of
    # @param query [Symbol, String] the predicate method to check on the policy (e.g. `:show?`).
    #   If omitted then this defaults to the Rails controller action name.
    # @param policy_class [Class] the policy class we want to force use of
    # @raise [NotAuthorizedError] if the given query method returned false
    # @return [record] Always returns the passed object record
    # @see Pundit::Context#authorize
    # @see #verify_authorized
    def authorize(record, query = nil, policy_class: nil)
      query ||= "#{action_name}?"

      @_pundit_policy_authorized = true

      pundit.authorize(record, query: query, policy_class: policy_class)
    end

    # Allow this action not to perform authorization.
    #
    # @see https://github.com/varvet/pundit#ensuring-policies-and-scopes-are-used
    # @return [void]
    # @see #verify_authorized
    def skip_authorization
      @_pundit_policy_authorized = :skipped
    end

    # @return [Boolean] wether or not authorization has been performed
    # @see #authorize
    # @see #skip_authorization
    def pundit_policy_authorized?
      !!@_pundit_policy_authorized
    end

    # Raises an error if authorization has not been performed.
    #
    # Usually used as an `after_action` filter to prevent programmer error in
    # forgetting to call {#authorize} or {#skip_authorization}.
    #
    # @see https://github.com/varvet/pundit#ensuring-policies-and-scopes-are-used
    # @raise [AuthorizationNotPerformedError] if authorization has not been performed
    # @return [void]
    # @see #authorize
    # @see #skip_authorization
    def verify_authorized
      raise AuthorizationNotPerformedError, self.class unless pundit_policy_authorized?
    end

    # rubocop:disable Naming/MemoizedInstanceVariableName

    # Cache of policies. You should not rely on this method.
    #
    # @api private
    def policies
      @_pundit_policies ||= {}
    end

    # rubocop:enable Naming/MemoizedInstanceVariableName

    # @!endgroup

    # Retrieves the policy for the given record.
    #
    # @see https://github.com/varvet/pundit#policies
    # @param record [Object] the object we're retrieving the policy for
    # @return [Object] instance of policy class with query methods
    def policy(record)
      pundit.policy!(record)
    end

    # @!group Policy Scopes

    # Retrieves the policy scope for the given record.
    #
    # @see https://github.com/varvet/pundit#scopes
    # @param scope [Object] the object we're retrieving the policy scope for
    # @param policy_scope_class [#resolve] the policy scope class we want to force use of
    # @return [#resolve, nil] instance of scope class which can resolve to a scope
    def policy_scope(scope, policy_scope_class: nil)
      @_pundit_policy_scoped = true
      policy_scope_class ? policy_scope_class.new(pundit_user, scope).resolve : pundit_policy_scope(scope)
    end

    # Allow this action not to perform policy scoping.
    #
    # @see https://github.com/varvet/pundit#ensuring-policies-and-scopes-are-used
    # @return [void]
    # @see #verify_policy_scoped
    def skip_policy_scope
      @_pundit_policy_scoped = :skipped
    end

    # @return [Boolean] wether or not policy scoping has been performed
    # @see #policy_scope
    # @see #skip_policy_scope
    def pundit_policy_scoped?
      !!@_pundit_policy_scoped
    end

    # Raises an error if policy scoping has not been performed.
    #
    # Usually used as an `after_action` filter to prevent programmer error in
    # forgetting to call {#policy_scope} or {#skip_policy_scope} in index
    # actions.
    #
    # @see https://github.com/varvet/pundit#ensuring-policies-and-scopes-are-used
    # @raise [AuthorizationNotPerformedError] if policy scoping has not been performed
    # @return [void]
    # @see #policy_scope
    # @see #skip_policy_scope
    def verify_policy_scoped
      raise PolicyScopingNotPerformedError, self.class unless pundit_policy_scoped?
    end

    # rubocop:disable Naming/MemoizedInstanceVariableName

    # Cache of policy scope. You should not rely on this method.
    #
    # @api private
    def policy_scopes
      @_pundit_policy_scopes ||= {}
    end

    # rubocop:enable Naming/MemoizedInstanceVariableName

    # This was added to allow calling `policy_scope!` without flipping the
    # `pundit_policy_scoped?` flag.
    #
    # It's used internally by `policy_scope`, as well as from the views
    # when they call `policy_scope`. It works because views get their helper
    # from {Pundit::Helper}.
    #
    # @note This also memoizes the instance with `scope` as the key.
    # @see Pundit::Helper#policy_scope
    # @api private
    def pundit_policy_scope(scope)
      policy_scopes[scope] ||= pundit.policy_scope!(scope)
    end
    private :pundit_policy_scope

    # @!endgroup

    # @!group Strong Parameters

    # Retrieves a set of permitted attributes from the policy.
    #
    # Done by instantiating the policy class for the given record and calling
    # `permitted_attributes` on it, or `permitted_attributes_for_{action}` if
    # `action` is defined. It then infers what key the record should have in the
    # params hash and retrieves the permitted attributes from the params hash
    # under that key.
    #
    # @see https://github.com/varvet/pundit#strong-parameters
    # @param record [Object] the object we're retrieving permitted attributes for
    # @param action [Symbol, String] the name of the action being performed on the record (e.g. `:update`).
    #   If omitted then this defaults to the Rails controller action name.
    # @return [Hash{String => Object}] the permitted attributes
    def permitted_attributes(record, action = action_name)
      policy = policy(record)
      method_name = if policy.respond_to?("permitted_attributes_for_#{action}")
        "permitted_attributes_for_#{action}"
      else
        "permitted_attributes"
      end
      pundit_params_for(record).permit(*policy.public_send(method_name))
    end

    # Retrieves the params for the given record.
    #
    # @param record [Object] the object we're retrieving params for
    # @return [ActionController::Parameters] the params
    def pundit_params_for(record)
      params.require(PolicyFinder.new(record).param_key)
    end

    # @!endgroup
  end
end
