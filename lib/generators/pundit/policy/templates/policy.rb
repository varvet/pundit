<% module_namespacing do -%>
class <%= class_name %>Policy < ApplicationPolicy
  def index?
    super
  end

  def create?
    super
  end

  def update?
    super
  end

  def delete?
    super
  end

  def permitted_attributes
    %i[]
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
<% end -%>
