# frozen_string_literal: true

class NilClassPolicy < BasePolicy
  class Scope
    def initialize(*)
      raise Pundit::NotDefinedError, "Cannot scope NilClass"
    end
  end

  def show?
    false
  end

  def destroy?
    false
  end
end
