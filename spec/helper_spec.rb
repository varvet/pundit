# frozen_string_literal: true

require "spec_helper"

describe Pundit::Helper do
  let(:user) { double }
  let(:post) { Post.new(user) }
  let(:view) { PostsView.new(user, post) }

  describe ".policy_scope" do
    it "returns an instantiated policy scope given a plain model class" do
      expect(view.policy_scope(Post)).to eq :published
    end

    it "raises an original error with a policy scope that contains argument error" do
      expect { view.policy_scope(user, Post) }.to raise_error(ArgumentError)
    end

    it "raises an exception if nil object given" do
      expect { view.policy_scope(nil) }.to raise_error(Pundit::NotDefinedError, "Cannot scope NilClass")
    end
  end
end
