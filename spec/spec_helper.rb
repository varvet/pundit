# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require "pundit"
require "pundit/rspec"

require "rack"
require "rack/test"
require "pry"
require "active_support"
require "active_support/core_ext"
require "active_model/naming"
require "action_controller/metal/strong_parameters"

module InstanceTracking
  module ClassMethods
    def instances
      @instances || 0
    end

    attr_writer :instances
  end

  def self.prepended(other)
    other.extend(ClassMethods)
  end

  def initialize(*args, **kwargs, &block)
    self.class.instances += 1
    super(*args, **kwargs, &block)
  end
end

class BasePolicy
  prepend InstanceTracking

  class BaseScope
    prepend InstanceTracking

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    attr_reader :user, :scope
  end

  def initialize(user, record)
    @user = user
    @record = record
  end

  attr_reader :user, :record
end

class PostPolicy < BasePolicy
  class Scope < BaseScope
    def resolve
      scope.published
    end
  end

  alias post record

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
      %i[title votes]
    else
      [:votes]
    end
  end

  def permitted_attributes_for_revise
    [:body]
  end
end

class Post
  def initialize(user = nil)
    @user = user
  end

  attr_reader :user

  def self.published
    :published
  end

  def self.read
    :read
  end

  def to_s
    "Post"
  end

  def inspect
    "#<Post>"
  end
end

module Customer
  class Post < ::Post
    def model_name
      OpenStruct.new(param_key: "customer_post")
    end

    def self.policy_class
      PostPolicy
    end
  end
end

class CommentScope
  attr_reader :original_object

  def initialize(original_object)
    @original_object = original_object
  end

  def ==(other)
    original_object == other.original_object
  end
end

class CommentPolicy < BasePolicy
  class Scope < BaseScope
    def resolve
      CommentScope.new(scope)
    end
  end

  alias comment record
end

class PublicationPolicy < BasePolicy
  class Scope < BaseScope
    def resolve
      scope.published
    end
  end

  def create?
    true
  end
end

class Comment
  extend ActiveModel::Naming
end

class CommentsRelation
  def initialize(empty: false)
    @empty = empty
  end

  def blank?
    @empty
  end

  def self.model_name
    Comment.model_name
  end
end

class Article; end

class BlogPolicy < BasePolicy
  alias blog record
end

class Blog; end

class ArtificialBlog < Blog
  def self.policy_class
    BlogPolicy
  end
end

class ArticleTagOtherNamePolicy < BasePolicy
  def show?
    true
  end

  def destroy?
    false
  end

  alias tag record
end

class ArticleTag
  def self.policy_class
    ArticleTagOtherNamePolicy
  end
end

class CriteriaPolicy < BasePolicy
  alias criteria record
end

module Project
  class CommentPolicy < BasePolicy
    class Scope < BaseScope
      def resolve
        scope
      end
    end

    def update?
      true
    end

    alias comment record
  end

  class CriteriaPolicy < BasePolicy
    alias criteria record
  end

  class PostPolicy < BasePolicy
    class Scope < BaseScope
      def resolve
        scope.read
      end
    end

    alias post record
  end

  module Admin
    class CommentPolicy < BasePolicy
      def update?
        true
      end

      def destroy?
        false
      end
    end
  end
end

class DenierPolicy < BasePolicy
  def update?
    false
  end
end

class Controller
  include Pundit::Authorization
  # Mark protected methods public so they may be called in test
  # rubocop:disable Style/AccessModifierDeclarations
  public(*Pundit::Authorization.protected_instance_methods)
  # rubocop:enable Style/AccessModifierDeclarations

  attr_reader :current_user, :action_name, :params

  def initialize(current_user, action_name, params)
    @current_user = current_user
    @action_name = action_name
    @params = params
  end
end

class NilClassPolicy < BasePolicy
  class Scope
    def initialize(*)
      raise Pundit::NotDefinedError, "Cannot scope NilClass"
    end
  end

  def show?
    false
  end

  def destroy?
    false
  end
end

class Wiki; end

class WikiPolicy
  class Scope
    # deliberate typo method
    def initalize; end
  end
end

class Thread
  def self.all; end
end

class ThreadPolicy < BasePolicy
  class Scope < BaseScope
    def resolve
      # deliberate wrong useage of the method
      scope.all(:unvalid, :parameters)
    end
  end
end

class PostFourFiveSix
  def initialize(user)
    @user = user
  end

  attr_reader(:user)
end

class CommentFourFiveSix; extend ActiveModel::Naming; end

module ProjectOneTwoThree
  class CommentFourFiveSixPolicy < BasePolicy; end

  class CriteriaFourFiveSixPolicy < BasePolicy; end

  class PostFourFiveSixPolicy < BasePolicy; end

  class TagFourFiveSix
    def initialize(user)
      @user = user
    end

    attr_reader(:user)
  end

  class TagFourFiveSixPolicy < BasePolicy; end

  class AvatarFourFiveSix; extend ActiveModel::Naming; end

  class AvatarFourFiveSixPolicy < BasePolicy; end
end
