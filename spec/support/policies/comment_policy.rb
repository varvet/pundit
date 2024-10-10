# frozen_string_literal: true

class CommentPolicy < BasePolicy
  class Scope < BaseScope
    def resolve
      CommentScope.new(scope)
    end
  end

  alias comment record
end
