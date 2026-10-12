# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pundit::Finder do
  subject(:finder) { described_class.new }

  let(:post) { Post.new }

  describe "#policy" do
    it "finds the policy class" do
      expect(finder.policy(post)).to be(PostPolicy)
      expect(finder.policy([:project, post])).to be(Project::PostPolicy)
    end

    it "returns nil when there is none" do
      expect(finder.policy(Article.new)).to be_nil
    end
  end

  describe "#scope" do
    it "finds the scope class" do
      expect(finder.scope(Post)).to be(PostPolicy::Scope)
      expect(finder.scope([:project, Post])).to be(Project::PostPolicy::Scope)
    end

    it "returns nil when there is none" do
      expect(finder.scope(Article)).to be_nil
    end
  end
end
