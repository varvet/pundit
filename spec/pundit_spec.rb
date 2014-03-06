require "ostruct"
require 'minitest/autorun'
require "pundit"
require "pry"
require "active_support/core_ext"
require "active_model/naming"

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

describe Pundit do
  let(:user) { OpenStruct.new }
  let(:post) { Post.new(user) }
  let(:comment) { Comment.new }
  let(:article) { Article.new }
  let(:controller) { OpenStruct.new(:current_user => user, :params => { :action => "update" }).tap { |c| c.extend(Pundit) } }
  let(:artificial_blog) { ArtificialBlog.new }
  let(:article_tag) { ArticleTag.new }

  describe ".policy_scope" do
    it "returns an instantiated policy scope given a plain model class" do
      assert_equal :published, Pundit.policy_scope(user, Post)
    end

    it "returns an instantiated policy scope given an active model class" do
      assert_equal Comment, Pundit.policy_scope(user, Comment)
    end

    it "returns nil if the given policy scope can't be found" do
      assert_nil Pundit.policy_scope(user, Article)
    end
  end

  describe ".policy_scope!" do
    it "returns an instantiated policy scope given a plain model class" do
      assert_equal :published, Pundit.policy_scope!(user, Post)
    end

    it "returns an instantiated policy scope given an active model class" do
      assert_equal Comment, Pundit.policy_scope!(user, Comment)
    end

    it "throws an exception if the given policy scope can't be found" do
      assert_raises(Pundit::NotDefinedError) { Pundit.policy_scope!(user, Article) }
    end

    it "throws an exception if the given policy scope can't be found" do
      assert_raises(Pundit::NotDefinedError) { Pundit.policy_scope!(user, ArticleTag) }
    end
  end

  describe ".policy" do
    it "returns an instantiated policy given a plain model instance" do
      policy = Pundit.policy(user, post)
      assert_equal user, policy.user
      assert_equal post, policy.post
    end

    it "returns an instantiated policy given an active model instance" do
      policy = Pundit.policy(user, comment)
      assert_equal user, policy.user
      assert_equal comment, policy.comment
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy(user, Post)
      assert_equal user, policy.user
      assert_equal Post, policy.post
    end

    it "returns an instantiated policy given an active model class" do
      policy = Pundit.policy(user, Comment)
      assert_equal user, policy.user
      assert_equal Comment, policy.comment
    end

    it "returns nil if the given policy can't be found" do
      assert_nil Pundit.policy(user, article)
      assert_nil Pundit.policy(user, Article)
    end

    describe "with .policy_class set on the model" do
      it "returns an instantiated policy given a plain model instance" do
        policy = Pundit.policy(user, artificial_blog)
        assert_equal user, policy.user
        assert_equal artificial_blog, policy.blog
      end

      it "returns an instantiated policy given a plain model class" do
        policy = Pundit.policy(user, ArtificialBlog)
        assert_equal user, policy.user
        assert_equal ArtificialBlog, policy.blog
      end

      it "returns an instantiated policy given a plain model instance providing an anonymous class" do
        policy = Pundit.policy(user, article_tag)
        assert_equal user, policy.user
        assert_equal article_tag, policy.tag
      end

      it "returns an instantiated policy given a plain model class providing an anonymous class" do
        policy = Pundit.policy(user, ArticleTag)
        assert_equal user, policy.user
        assert_equal ArticleTag, policy.tag
      end
    end
  end

  describe ".policy!" do
    it "returns an instantiated policy given a plain model instance" do
      policy = Pundit.policy!(user, post)
      assert_equal user, policy.user
      assert_equal post, policy.post
    end

    it "returns an instantiated policy given an active model instance" do
      policy = Pundit.policy!(user, comment)
      assert_equal user, policy.user
      assert_equal comment, policy.comment
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy!(user, Post)
      assert_equal user, policy.user
      assert_equal Post, policy.post
    end

    it "returns an instantiated policy given an active model class" do
      policy = Pundit.policy!(user, Comment)
      assert_equal user, policy.user
      assert_equal Comment, policy.comment
    end

    it "throws an exception if the given policy can't be found" do
      assert_raises(Pundit::NotDefinedError) { Pundit.policy!(user, article) }
      assert_raises(Pundit::NotDefinedError) { Pundit.policy!(user, Article) }
    end
  end

  describe "#verify_authorized" do
    it "does nothing when authorized" do
      controller.authorize(post)
      controller.verify_authorized
    end

    it "raises an exception when not authorized" do
      assert_raises(Pundit::NotAuthorizedError) { controller.verify_authorized }
    end
  end

  describe "#verify_policy_scoped" do
    it "does nothing when policy_scope is used" do
      controller.policy_scope(Post)
      controller.verify_policy_scoped
    end

    it "raises an exception when policy_scope is not used" do
      assert_raises(Pundit::NotAuthorizedError) { controller.verify_policy_scoped }
    end
  end

  describe "#authorize" do
    it "infers the policy name and authorized based on it" do
      assert_equal true, controller.authorize(post)
    end

    it "can be given a different permission to check" do
      assert_equal true, controller.authorize(post, :show?)
      assert_raises(Pundit::NotAuthorizedError) { controller.authorize(post, :destroy?) }
    end

    it "works with anonymous class policies" do
      assert_equal true, controller.authorize(article_tag, :show?)
      assert_raises(Pundit::NotAuthorizedError) { controller.authorize(article_tag, :destroy?) }
    end

    it "raises an error when the permission check fails" do
      assert_raises(Pundit::NotAuthorizedError) { controller.authorize(Post.new) }
    end

    it "raises an error with a query and action" do
      error = assert_raises(Pundit::NotAuthorizedError) { controller.authorize(post, :destroy?) }
      assert_equal :destroy?, error.query
      assert_equal post, error.record
      assert_equal controller.policy(post), error.policy
    end
  end

  describe "#pundit_user" do
    it 'returns the same thing as current_user' do
      assert_equal controller.current_user, controller.pundit_user
    end
  end

  describe ".policy" do
    it "returns an instantiated policy" do
      policy = controller.policy(post)
      assert_equal user, policy.user
      assert_equal post, policy.post
    end

    it "throws an exception if the given policy can't be found" do
      assert_raises(Pundit::NotDefinedError) { controller.policy(article) }
    end

    it "allows policy to be injected" do
      new_policy = OpenStruct.new
      controller.policy = new_policy

      assert_equal new_policy, controller.policy(post)
    end
  end

  describe ".policy_scope" do
    it "returns an instantiated policy scope" do
      assert_equal :published, controller.policy_scope(Post)
    end

    it "throws an exception if the given policy can't be found" do
      assert_raises(Pundit::NotDefinedError) { controller.policy_scope(Article) }
    end

    it "allows policy_scope to be injected" do
      new_scope = OpenStruct.new
      controller.policy_scope = new_scope

      assert_equal new_scope, controller.policy_scope(post)
    end
  end
end
