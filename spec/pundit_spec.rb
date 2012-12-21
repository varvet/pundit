require "pundit"
require "pry"
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

# for testing that we can find an inherited scope
class SpecialPostPolicy < PostPolicy; end
class SpecialPost < Post; end

class Article; end

describe Pundit do
  let(:user) { stub }
  let(:post) { Post.new(user) }
  let(:special_post) { SpecialPost.new(user) }
  let(:comment) { Comment.new }
  let(:article) { Article.new }
  let(:controller) { stub(:current_user => user, :params => { :action => "update" }).tap { |c| c.extend(Pundit) } }

  describe ".policy_scope" do
    it "returns an instantiated policy scope given a plain model class" do
      Pundit.policy_scope(user, Post).should == :published
    end
    
    it "returns an instantiated inherited policy scope" do
      Pundit.policy_scope(user, SpecialPost).should == :published
    end

    it "returns an instantiated policy scope given an active model class" do
      Pundit.policy_scope(user, Comment).should == Comment
    end

    it "returns nil if the given policy scope can't be found" do
      Pundit.policy_scope(user, Article).should be_nil
    end
  end

  describe ".policy_scope!" do
    it "returns an instantiated policy scope given a plain model class" do
      Pundit.policy_scope!(user, Post).should == :published
    end

    it "returns an inherited instantiated policy scope" do
      Pundit.policy_scope!(user, SpecialPost).should == :published
    end

    it "returns an instantiated policy scope given an active model class" do
      Pundit.policy_scope!(user, Comment).should == Comment
    end

    it "throws an exception if the given policy scope can't be found" do
      expect { Pundit.policy_scope!(user, Article) }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe ".policy" do
    it "returns an instantiated policy given a plain model instance" do
      policy = Pundit.policy(user, post)
      policy.user.should == user
      policy.post.should == post
    end

    it "returns an instantiated policy given an active model instance" do
      policy = Pundit.policy(user, comment)
      policy.user.should == user
      policy.comment.should == comment
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy(user, Post)
      policy.user.should == user
      policy.post.should == Post
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy(user, SpecialPost)
      policy.user.should == user
      policy.post.should == SpecialPost
    end

    it "returns an instantiated policy given an active model class" do
      policy = Pundit.policy(user, Comment)
      policy.user.should == user
      policy.comment.should == Comment
    end

    it "returns nil if the given policy can't be found" do
      Pundit.policy(user, article).should be_nil
      Pundit.policy(user, Article).should be_nil
    end
  end

  describe ".policy!" do
    it "returns an instantiated policy given a plain model instance" do
      policy = Pundit.policy!(user, post)
      policy.user.should == user
      policy.post.should == post
    end

    it "returns an instantiated policy given an inherited plain model instance" do
      policy = Pundit.policy!(user, special_post)
      policy.user.should == user
      policy.post.should == special_post
    end

    it "returns an instantiated policy given an active model instance" do
      policy = Pundit.policy!(user, comment)
      policy.user.should == user
      policy.comment.should == comment
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy!(user, Post)
      policy.user.should == user
      policy.post.should == Post
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy!(user, SpecialPost)
      policy.user.should == user
      policy.post.should == SpecialPost
    end

    it "returns an instantiated policy given an active model class" do
      policy = Pundit.policy!(user, Comment)
      policy.user.should == user
      policy.comment.should == Comment
    end

    it "throws an exception if the given policy can't be found" do
      expect { Pundit.policy!(user, article) }.to raise_error(Pundit::NotDefinedError)
      expect { Pundit.policy!(user, Article) }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe "#verify_authorized" do
    it "does nothing when authorized" do
      controller.authorize(post)
      controller.verify_authorized
    end

    it "raises an exception when not authorized" do
      expect { controller.verify_authorized }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "#authorize" do
    it "infers the policy name and authorized based on it" do
      controller.authorize(post).should be_true
    end

    it "can be given a different permission to check" do
      controller.authorize(post, :show?).should be_true
      expect { controller.authorize(post, :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "raises an error when the permission check fails" do
      expect { controller.authorize(Post.new) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe ".policy" do
    it "returns an instantiated policy" do
      policy = controller.policy(post)
      policy.user.should == user
      policy.post.should == post
    end

    it "throws an exception if the given policy can't be found" do
      expect { controller.policy(article) }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe ".policy_scope" do
    it "returns an instantiated policy scope" do
      controller.policy_scope(Post).should == :published
    end

    it "returns an instantiated inherited policy scope" do
      controller.policy_scope(SpecialPost).should == :published
    end

    it "throws an exception if the given policy can't be found" do
      expect { controller.policy_scope(Article) }.to raise_error(Pundit::NotDefinedError)
    end
  end
end
