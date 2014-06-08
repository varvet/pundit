<% module_namespacing do -%>
class <%= class_name %>Policy < ApplicationPolicy
  Scope = Struct.new(:user, :scope) do
    def resolve
      scope
    end
  end
end
<% end -%>
