<% module_namespacing do -%>
class <%= class_name %>Policy < ApplicationPolicy
  class Scope < Scope
    def resolve
      raise NotImplementedError, 'You need to implement this before using the scope'
    end
  end
end
<% end -%>
