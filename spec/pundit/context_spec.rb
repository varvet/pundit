# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pundit::Context do
  let(:user) { double }
  let(:post) { Post.new(user) }
  let(:comment) { Comment.new }
  let(:article) { Article.new }
  let(:context) { described_class.new(user: user) }

  def authorize(record, query:, policy_class: nil)
    context.authorize(record, query: query, policy_class: policy_class)
  end

  describe "#authorize" do
    it "returns the record when authorized" do
      expect(authorize(post, query: :update?)).to be(post)
    end

    it "raises when not authorized" do
      expect { authorize(Post.new, query: :update?) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "returns the record when given a namespaced record" do
      expect(authorize([:project, comment], query: :update?)).to be(comment)
    end

    it "uses an explicit policy class" do
      expect(authorize(post, query: :create?, policy_class: PublicationPolicy)).to be(post)
    end

    it "raises when the policy cannot be found" do
      expect { authorize(article, query: :update?) }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe "#policy" do
    it "returns an instantiated policy" do
      policy = context.policy(post)

      expect(policy).to be_a(PostPolicy)
      expect(policy.user).to be(user)
      expect(policy.record).to be(post)
    end

    it "returns nil when the policy cannot be found" do
      expect(context.policy(article)).to be_nil
    end

    it "raises when the policy constructor is invalid" do
      expect { context.policy(Wiki.new) }.to raise_error(Pundit::InvalidConstructorError)
    end
  end

  describe "#policy!" do
    it "raises when the policy cannot be found" do
      expect { context.policy!(article) }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe "#policy_scope" do
    it "resolves the scope" do
      expect(context.policy_scope(Post)).to eq(:published)
    end

    it "resolves a namespaced scope" do
      expect(context.policy_scope([:project, Post])).to eq(:read)
    end

    it "returns nil when the scope cannot be found" do
      expect(context.policy_scope(Article)).to be_nil
    end
  end

  describe "#policy_scope!" do
    it "raises when the scope cannot be found" do
      expect { context.policy_scope!(Article) }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe "policy cache" do
    it "fetches policies through it" do
      store = {}
      context = described_class.new(user: user, policy_cache: Pundit::CacheStore::LegacyStore.new(store))

      policy = context.policy(post)

      expect(context.policy(post)).to be(policy)
      expect(store).to eq({post => policy})
    end
  end

  describe "#with" do
    it "returns a new context with the given collaborators swapped and the rest kept" do
      user = double
      cache = double
      finder = double
      context = described_class.new(user: user, policy_cache: cache).with(finder: finder)

      expect(context).to be_a(described_class)
      expect(context.user).to be(user)
      expect(context.policy_cache).to be(cache)
      expect(context.finder).to be(finder)
    end
  end

  context "finding" do
    describe "finder injection" do
      it "finds policies through it" do
        finder = double(policy: PublicationPolicy)
        context = described_class.new(user: user, finder: finder)

        expect(context.policy(post)).to be_a(PublicationPolicy)
        expect(context.policy!(post)).to be_a(PublicationPolicy)
        expect(finder).to have_received(:policy).with(post).twice
      end

      it "raises when the finder finds no policy" do
        finder = double(policy: nil)
        context = described_class.new(user: user, finder: finder)

        expect { context.policy!(post) }.to raise_error(Pundit::NotDefinedError, "unable to find policy for `#{post.inspect}`")
      end

      it "finds scopes through it" do
        finder = double(scope: PublicationPolicy::Scope)
        context = described_class.new(user: user, finder: finder)

        expect(context.policy_scope(Post)).to eq(:published)
        expect(context.policy_scope!(Post)).to eq(:published)
        expect(finder).to have_received(:scope).with(Post).twice
      end
    end
  end
end
