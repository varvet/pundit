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
      policy_scope = PolicyFinder.new(scope).scope
      policy_scope.new(user, scope).resolve if policy_scope
    end

    def policy_scope!(user, scope)
      PolicyFinder.new(scope).scope!.new(user, scope).resolve
    end

    def policy(user, record)
      policy = PolicyFinder.new(record).policy
      policy.new(user, record) if policy
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

  def verify_authorized(*secure_classes)
    unless policy_authorized_classes.present? && all_specified_classes_authorized?(secure_classes)
      raise NotAuthorizedError
    end
  end

  def verify_policy_scoped(*secure_classes)
    unless policy_scoped_classes.present? && all_specified_classes_policy_scoped?(secure_classes)
      raise NotAuthorizedError
    end
  end

  def authorize(record, query=nil)
    query ||= params[:action].to_s + "?"
    policy_authorized_classes << class_name_for(record)
    unless policy(record).public_send(query)
      raise NotAuthorizedError, "not allowed to #{query} this #{record}"
    end
    true
  end

  def policy_scope(scope)
    policy_scoped_classes << class_name_for(scope)
    @policy_scope or Pundit.policy_scope!(pundit_user, scope)
  end
  attr_writer :policy_scope

  def policy(record)
    @policy or Pundit.policy!(pundit_user, record)
  end
  attr_writer :policy

  def pundit_user
    current_user
  end

  private
  def policy_authorized_classes
    @_policy_authorized_classes ||= []
  end

  def policy_scoped_classes
    @_policy_scoped_classes ||= []
  end

  def all_specified_classes_authorized?(classes)
    classes.empty? || classes.all? { |c| authorized_class? c }
  end

  def authorized_class?(klass)
    policy_authorized_classes.include? klass
  end

  def all_specified_classes_policy_scoped?(classes)
    classes.empty? || classes.all? { |c| policy_scoped_class? c }
  end

  def policy_scoped_class?(klass)
    policy_scoped_classes.include? klass
  end

  def class_name_for(item)
    if scope.respond_to? :model_name
      scope.model_name.name.constantize
    elsif scope.is_a? Class
      scope
    else
      scope.class
    end
  end
end
