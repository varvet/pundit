# frozen_string_literal: true

class ArticleTagOtherNamePolicy < BasePolicy
  def show?
    true
  end

  def destroy?
    false
  end

  alias_method :tag, :record
end
