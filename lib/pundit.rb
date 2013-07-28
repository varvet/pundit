require "pundit/version"
require "pundit/policy_finder"
require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"

module Pundit
  class Error < StandardError; end

  # Raised when an authorize call returns an untruthy value
  class NotAuthorized < Pundit::Error; end

  # Raised when an authorize call is expected but not performed
  class AuthorizationNotPerformed < Pundit::Error; end

  # Raised when a scope is expected to be but has not been applied
  class ScopeNotApplied < Pundit::Error; end

  # Raised when a scope or a policy cannot be found
  class NotDefined < Pundit::Error; end

  extend ActiveSupport::Concern

  class << self
    def policy_scope(user, scope)
      policy = PolicyFinder.new(scope).scope
      policy.new(user, scope).resolve if policy
    end

    def policy_scope!(user, scope)
      PolicyFinder.new(scope).scope!.new(user, scope).resolve
    end

    def policy(user, record)
      scope = PolicyFinder.new(record).policy
      scope.new(user, record) if scope
    end

    def policy!(user, record)
      PolicyFinder.new(record).policy!.new(user, record)
    end
  end

  included do
    if respond_to?(:helper_method)
      helper_method :policy_scope
      helper_method :policy
      helper_method :pundit_user
    end
    if respond_to?(:hide_action)
      hide_action :authorize
      hide_action :verify_authorized
      hide_action :verify_policy_scoped
      hide_action :pundit_user
    end
  end

  def verify_authorized
    raise Error::AuthorizationNotPerformed unless @_policy_authorized
  end

  def verify_policy_scoped
    raise Error::ScopeNotApplied unless @_policy_scoped
  end

  def authorize(record, query=nil)
    query ||= params[:action].to_s + "?"
    @_policy_authorized = true
    unless policy(record).public_send(query)
      raise Error::NotAuthorized, "not allowed to #{query} this #{record}"
    end
    true
  end

  def policy_scope(scope)
    @_policy_scoped = true
    Pundit.policy_scope!(pundit_user, scope)
  end

  def policy(record)
    Pundit.policy!(pundit_user, record)
  end

  def pundit_user
    current_user
  end
end
