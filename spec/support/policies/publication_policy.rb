# frozen_string_literal: true

class PublicationPolicy < BasePolicy
  class Scope < BaseScope
    def resolve
      scope.published
    end
  end

  def create?
    true
  end

  def permitted_attributes
    %i[title body]
  end
end
