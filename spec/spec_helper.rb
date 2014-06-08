require "pundit"
require "pry"
require "active_support/core_ext"
require "active_model/naming"

PostPolicy = Struct.new(:user, :post) do
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
PostPolicy::Scope = Struct.new(:user, :scope) do
  def resolve
    scope.published
  end
end
Post = Struct.new(:user) do
  def self.published
    :published
  end
end

CommentPolicy = Struct.new(:user, :comment)
CommentPolicy::Scope = Struct.new(:user, :scope) do
  def resolve
    scope
  end
end
class Comment; extend ActiveModel::Naming; end

class Article; end

BlogPolicy = Struct.new(:user, :blog)
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

class Controller
  include Pundit

  attr_reader :current_user, :params

  def initialize(current_user, params)
    @current_user = current_user
    @params = params
  end
end

module Admin
  CommentPolicy = Struct.new(:user, :comment)
  class Controller
    include Pundit

    attr_reader :current_user, :params
  end
end
