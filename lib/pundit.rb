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
    def policy_scope(user, scope, *args)
      scope_class = PolicyFinder.new(scope).scope
      scope_class.new(user, scope, *args).resolve if scope_class
    end

    def policy_scope!(user, scope, *args)
      PolicyFinder.new(scope).scope!.new(user, scope, *args).resolve
    end

    def policy(user, record, *args)
      policy = PolicyFinder.new(record).policy
      policy.new(user, record, *args) if policy
    end

    def policy!(user, record, *args)
      PolicyFinder.new(record).policy!.new(user, record, *args)
    end
  end

  included do
    if respond_to?(:helper_method)
      helper_method :policy_scope
      helper_method :policy
    end
  end

  def verify_authorized
    raise NotAuthorizedError unless @_policy_authorized
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
    Pundit.policy_scope!(current_user, scope)
  end

  def policy(record)
    Pundit.policy!(current_user, record)
  end
end
