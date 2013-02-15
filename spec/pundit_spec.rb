require "pundit"
require "pry"
require "active_model/naming"
require "action_controller"

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

  def resolve
    post.published
  end
end
class Post < Struct.new(:user)
  def self.published
    :published
  end
end

class CommentPolicy < Struct.new(:user, :comment)
  def resolve
    comment
  end
end
class Comment; extend ActiveModel::Naming; end

class Article; end

# for testing that we can find a mapped Policy
class SpecialPost < Post; end
class SpecialPostsController < ActionController::Base
  include Pundit
  def current_user
  end
  protected
  def policy_map
    { :special_post => :post}
  end
end

describe Pundit do
  let(:user) { stub }
  let(:post) { Post.new(user) }
  let(:comment) { Comment.new }
  let(:article) { Article.new }
  let(:controller) { stub(:current_user => user, :params => { :action => "update" }).tap { |c| c.extend(Pundit) } }

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

    it "throws an exception if the given policy can't be found" do
      expect { controller.policy_scope(Article) }.to raise_error(Pundit::NotDefinedError)
    end
  end
end

describe SpecialPostsController do
  let(:user) { stub }
  let(:special_post) { SpecialPost.new(user) }

  it "returns an instantiated policy scope from a mapped policy" do
    subject.policy_scope(SpecialPost).should == :published
  end
end
