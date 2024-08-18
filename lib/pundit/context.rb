# frozen_string_literal: true

module Pundit
  class Context
    def initialize(user:, policy_cache: CacheStore::NullStore.instance)
      @user = user
      @policy_cache = policy_cache
    end

    attr_reader :user

    # @api private
    attr_reader :policy_cache

    # Retrieves the policy for the given record, initializing it with the
    # record and user and finally throwing an error if the user is not
    # authorized to perform the given action.
    #
    # @param user [Object] the user that initiated the action
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

    # Retrieves the policy scope for the given record.
    #
    # @see https://github.com/varvet/pundit#scopes
    # @param user [Object] the user that initiated the action
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
    # @param user [Object] the user that initiated the action
    # @param scope [Object] the object we're retrieving the policy scope for
    # @raise [NotDefinedError] if the policy scope cannot be found
    # @raise [InvalidConstructorError] if the policy constructor called incorrectly
    # @return [Scope{#resolve}] instance of scope class which can resolve to a scope
    def policy_scope!(scope)
      policy_scope_class = policy_finder(scope).scope!
      return unless policy_scope_class

      begin
        policy_scope = policy_scope_class.new(user, pundit_model(scope))
      rescue ArgumentError
        raise InvalidConstructorError, "Invalid #<#{policy_scope_class}> constructor is called"
      end

      policy_scope.resolve
    end

    # Retrieves the policy for the given record.
    #
    # @see https://github.com/varvet/pundit#policies
    # @param user [Object] the user that initiated the action
    # @param record [Object] the object we're retrieving the policy for
    # @raise [InvalidConstructorError] if the policy constructor called incorrectly
    # @return [Object, nil] instance of policy class with query methods
    def policy(record)
      cached_find(record, &:policy)
    end

    # Retrieves the policy for the given record. Raises if not found.
    #
    # @see https://github.com/varvet/pundit#policies
    # @param user [Object] the user that initiated the action
    # @param record [Object] the object we're retrieving the policy for
    # @raise [NotDefinedError] if the policy cannot be found
    # @raise [InvalidConstructorError] if the policy constructor called incorrectly
    # @return [Object] instance of policy class with query methods
    def policy!(record)
      cached_find(record, &:policy!)
    end

    # Retrieves a set of permitted attributes from the policy by instantiating
    # the policy class for the given record and calling `permitted_attributes` on
    # it, or `permitted_attributes_for_{action}` if `action` is defined. It then infers
    # what key the record should have in the params hash and retrieves the
    # permitted attributes from the params hash under that key.
    #
    # @see https://github.com/varvet/pundit#strong-parameters
    # @param record [Object] the object we're retrieving permitted attributes for
    # @param action [Symbol, String] the name of the action being performed on the record (e.g. `:update`).
    # @param required_params [ActionController::Parameters] the params
    # @param policy_class [Class] the policy class we want to force use of
    # @return [Hash{String => Object}] the permitted attributes
    def permitted_attributes(record, action:, required_params:, policy_class: nil)
      policy = policy_class ? policy_class.new(user, record) : policy(record)
      method_name = if policy.respond_to?("permitted_attributes_for_#{action}")
        "permitted_attributes_for_#{action}"
      else
        "permitted_attributes"
      end
      required_params.permit(*policy.public_send(method_name))
    end

    private

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

    def policy_finder(record)
      PolicyFinder.new(record)
    end

    def pundit_model(record)
      record.is_a?(Array) ? record.last : record
    end
  end
end
