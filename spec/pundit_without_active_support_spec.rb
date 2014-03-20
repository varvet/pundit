require "pundit"
require "pry"
require 'spec_helper'

describe  'Pundit plain' do
  module Plain ; end
  class Plain::PostPolicy < Struct.new(:user, :post)
    def update?
      post.user == user
    end
    def destroy?
      false
    end
    def show?
      true
    end
  end
  class Plain::PostPolicy::Scope < Struct.new(:user, :scope)
    def resolve
      scope.published
    end
  end
  class Plain::Post < Struct.new(:user)
    def self.published
      :published
    end
  end

  class Plain::CommentPolicy < Struct.new(:user, :comment); end
  class Plain::CommentPolicy::Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
  class Plain::Comment;; end

  class Plain::Article; end

  class Plain::BlogPolicy < Struct.new(:user, :blog); end
  class Plain::Blog; end
  class Plain::ArtificialBlog < Plain::Blog
    def self.policy_class
      Plain::BlogPolicy
    end
  end
  class Plain::ArticleTag
    def self.policy_class
      Struct.new(:user, :tag) do
        def show?
          true
        end
        def destroy?
          false
        end
      end
    end
  end

  SpecHelper.pundit_examples(self, Plain)
end
