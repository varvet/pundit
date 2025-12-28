# frozen_string_literal: true

module Project
  class CriteriaPolicy < BasePolicy
    alias_method :criteria, :record
  end
end
