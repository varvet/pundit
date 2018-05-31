<% module_namespacing do -%>
class <%= class_name %>Policy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
<% end -%>
