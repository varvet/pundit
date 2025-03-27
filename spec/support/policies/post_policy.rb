# frozen_string_literal: true

class PostPolicy < BasePolicy
  class Scope < BaseScope
    def resolve
      scope.published
    end
  end

  alias_method :post, :record

  def update?
    post.user == user
  end
  alias_method :edit?, :update?

  def destroy?
    false
  end

  def show?
    true
  end

  def permitted_attributes
    if post.user == user
      %i[title votes]
    else
      [:votes]
    end
  end

  def permitted_attributes_for_revise
    [:body]
  end

  def expected_attributes
    if post.user == user
      %i[title votes]
    else
      [:votes]
    end
  end

  def expected_attributes_for_revise
    [:body]
  end
end
