# frozen_string_literal: true

class DummyCurrentUserPolicy < BasePolicy
  class Scope < BasePolicy::BaseScope
    def resolve
      user
    end
  end
end
