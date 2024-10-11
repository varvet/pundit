# frozen_string_literal: true

class DefaultScopeContainsErrorPolicy < BasePolicy
  class Scope < BaseScope
    def resolve
      # deliberate wrong usage of the method
      raise "This is an arbitrary error that should bubble up"
    end
  end
end
