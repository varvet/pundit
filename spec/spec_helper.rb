require "pundit"
require "pundit/rspec"

require "rack"
require "rack/test"
require "pry"
require "active_support"
require "active_support/core_ext"
require "active_model/naming"
require "action_controller/metal/strong_parameters"

I18n.enforce_available_locales = false

module PunditSpecHelper
  extend RSpec::Matchers::DSL

  matcher :be_truthy do
    match do |actual|
      actual
    end
  end
end

RSpec.configure do |config|
  config.include PunditSpecHelper
end

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
  def permitted_attributes
    if post.user == user
      [:title, :votes]
    else
      [:votes]
    end
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
  def to_s; "Post"; end
  def inspect; "#<Post>"; end
end

class CommentPolicy < Struct.new(:user, :comment); end
class CommentPolicy::Scope < Struct.new(:user, :scope)
  def resolve
    scope
  end
end
class Comment; extend ActiveModel::Naming; end

# minimum mock for an ActiveRecord Relation returning comments
class CommentsRelation
  def initialize(empty=false); @empty=empty; end
  def blank?; @empty; end
  def model_name; Comment.model_name; end
end

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

class CriteriaPolicy < Struct.new(:user, :criteria); end

module Project
  class CriteriaPolicy < Struct.new(:user, :criteria); end
end

class DenierPolicy < Struct.new(:user, :record)
  def update?
    false
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

class NilClassPolicy
  class Scope
    def initialize(*)
      raise "I'm only here to be annoying!"
    end
  end

  def initialize(*)
    raise "I'm only here to be annoying!"
  end
end
