require "pundit/version"
require "pundit/policy_finder"
require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"

module Pundit
  class NotAuthorizedError < StandardError; end
  class NotDefinedError < StandardError; end

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
    end
    if respond_to?(:hide_action)
      hide_action :authorize
      hide_action :verify_authorized
      hide_action :verify_policy_scoped
    end
  end

  def verify_authorized
    raise NotAuthorizedError unless @_policy_authorized
  end

  def verify_policy_scoped
    raise NotAuthorizedError unless @_policy_scoped
  end

  def authorize(record, query=nil)
    query ||= params[:action].to_s + "?"
    @_policy_authorized = true
    unless policy(record).public_send(query)
      raise NotAuthorizedError, "not allowed to #{query} this #{record}"
    end
    true
  end

  def policy_scope(scope)
    @_policy_scoped = true
    Pundit.policy_scope!(current_user, scope)
  end

  def policy(record)
    Pundit.policy!(current_user, record)
  end
end
