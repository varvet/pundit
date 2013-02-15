require "pundit/version"
require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"

module Pundit
  class NotAuthorizedError < StandardError; end
  class NotDefinedError < StandardError; end

  extend ActiveSupport::Concern

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

  def policy_scope(scope = collection)
    policy(scope).resolve
  end

  def policy(target = resource)
    policy_class!(target).new(current_user, target)
  end

  def policy_class!(target = resource)
    policy_class(target) or raise NotDefinedError, "unable to find policy for #{target}"
  end

  def policy_class(target = resource)
    policy_class_name(target).safe_constantize || 'ResourcePolicy'.safe_constantize || 'ApplicationPolicy'.safe_constantize
  end

  protected

  def policy_class_name(target)
    "#{policy_qualifier(target)}Policy"
  end

  def policy_qualifier(target)
    mq = model_qualifier(target)
    (policy_map.stringify_keys[mq.underscore].to_s.camelize if respond_to?(:policy_map)) || mq
  end

  def model_qualifier(target)
    case

    when target.respond_to?(:model_name)
      target.model_name.to_s

    when target.class.respond_to?(:model_name)
      target.class.model_name.to_s

    when target.is_a?(Class)
      target.to_s

    else
      target.class.to_s
    end
  end
end
