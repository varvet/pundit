# frozen_string_literal: true

class DenierPolicy < BasePolicy
  def update?
    false
  end
end
