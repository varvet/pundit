require "pundit"
require "pry"
require "active_support/core_ext"
require "active_model/naming"
require 'spec_helper'

module AS
  class PostPolicy < Struct.new(:user, :post)
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
  class PostPolicy::Scope < Struct.new(:user, :scope)
    def resolve
      scope.published
    end
  end
  class Post < Struct.new(:user)
    def self.published
      :published
    end
  end

  class CommentPolicy < Struct.new(:user, :comment); end
  class CommentPolicy::Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
  class Comment; extend ActiveModel::Naming; end

  class Article; end

  class BlogPolicy < Struct.new(:user, :blog); end
  class Blog; end
  class ArtificialBlog < Blog
    def self.policy_class
      BlogPolicy
    end
  end
  class ArticleTag
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
end
SpecHelper.pundit_examples(self, AS)