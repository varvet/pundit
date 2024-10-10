# frozen_string_literal: true

class BasePolicy
  prepend InstanceTracking

  class BaseScope
    prepend InstanceTracking

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    attr_reader :user, :scope
  end

  def initialize(user, record)
    @user = user
    @record = record
  end

  attr_reader :user, :record
end
