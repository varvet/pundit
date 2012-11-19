<% module_namespacing do -%>
class <%= class_name %>Policy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
<% end -%>
