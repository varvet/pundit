require "pundit/version"
require "pundit/policy_finder"
require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/introspection"
require "active_support/dependencies/autoload"

module Pundit
  class NotAuthorizedError < StandardError
    attr_accessor :query, :record, :policy
  end
  class AuthorizationNotPerformedError < StandardError; end
  class PolicyScopingNotPerformedError < AuthorizationNotPerformedError; end
  class NotDefinedError < StandardError; end

  extend ActiveSupport::Concern

  class << self
    def policy_scope(user, scope, namespace = Object)
      policy_scope = PolicyFinder.new(scope, namespace).scope
      policy_scope.new(user, scope).resolve if policy_scope
    end

    def policy_scope!(user, scope, namespace = Object)
      PolicyFinder.new(scope, namespace).scope!.new(user, scope).resolve
    end

    def policy(user, record, namespace = Object)
      policy = PolicyFinder.new(record, namespace).policy
      policy.new(user, record) if policy
    end

    def policy!(user, record, namespace = Object)
      PolicyFinder.new(record, namespace).policy!.new(user, record)
    end
  end

  included do
    if respond_to?(:helper_method)
      helper_method :policy_scope
      helper_method :policy
      helper_method :pundit_user
    end
    if respond_to?(:hide_action)
      hide_action :policy_scope
      hide_action :policy_scope=
      hide_action :policy
      hide_action :policy=
      hide_action :authorize
      hide_action :verify_authorized
      hide_action :verify_policy_scoped
      hide_action :policy_namespace
      hide_action :pundit_user
    end
  end

  def verify_authorized
    raise AuthorizationNotPerformedError unless @_policy_authorized
  end

  def verify_policy_scoped
    raise PolicyScopingNotPerformedError unless @_policy_scoped
  end

  def authorize(record, query=nil)
    query ||= params[:action].to_s + "?"
    @_policy_authorized = true

    policy = policy(record)
    unless policy.public_send(query)
      error = NotAuthorizedError.new("not allowed to #{query} this #{record}")
      error.query, error.record, error.policy = query, record, policy

      raise error
    end

    true
  end

  def policy_scope(scope, namespace = nil)
    @_policy_scoped = true
    @policy_scope or Pundit.policy_scope!(pundit_user, scope, find_namespace(namespace))
  end
  attr_writer :policy_scope

  def policy(record, namespace = nil)
    @_policy or Pundit.policy!(pundit_user, record, find_namespace(namespace))
  end

  def policy=(policy)
    @_policy = policy
  end

  def pundit_user
    current_user
  end

  def policy_namespace
    namespace = self.class.name.deconstantize
    return Object if namespace.empty?
    namespace.constantize
  end

  private

  def find_namespace(namespace = nil)
    return nil if namespace == false
    return namespace if namespace
    policy_namespace
  end
end
