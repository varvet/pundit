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

  context "namespacing" do
    describe "namespace injection" do
      it "wraps records through it before lookup" do
        namespace = double(wrap: [:project, comment])
        context = described_class.new(user: user, namespace: namespace)

        expect(context.policy(comment)).to be_a(Project::CommentPolicy)
        expect(namespace).to have_received(:wrap).with(comment)
      end
    end

    describe "#with_namespace" do
      let(:context) { described_class.new(user: user).with_namespace(:project) }

      it "returns a new context looking up under the namespace" do
        expect(context).to be_a(described_class)
        expect(context.policy(comment)).to be_a(Project::CommentPolicy)
      end

      it "keeps the user and policy cache" do
        user = double
        cache = double
        context = described_class.new(user: user, policy_cache: cache).with_namespace(:project)

        expect(context.user).to be(user)
        expect(context.policy_cache).to be(cache)
      end
    end

    context "with a namespace" do
      let(:context) { described_class.new(user: user, namespace: Pundit::Namespace.new(:project)) }

      it "looks up policies under the namespace" do
        expect(context.policy(comment)).to be_a(Project::CommentPolicy)
        expect(context.policy!(comment)).to be_a(Project::CommentPolicy)
      end

      it "looks up policy scopes under the namespace" do
        expect(context.policy_scope(Post)).to eq(:read)
        expect(context.policy_scope!(Post)).to eq(:read)
      end

      it "authorizes under the namespace" do
        expect(authorize(comment, query: :update?)).to be(comment)
      end

      it "namespaces explicitly namespaced records too" do
        expect(context.policy([:admin, comment])).to be_a(Project::Admin::CommentPolicy)
        expect { authorize([:admin, comment], query: :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
      end

      it "is bypassed by an explicit policy class" do
        expect(authorize(comment, query: :create?, policy_class: PublicationPolicy)).to be(comment)
      end

      it "caches by the namespaced record" do
        store = {}
        context = described_class.new(
          user: user,
          policy_cache: Pundit::CacheStore::LegacyStore.new(store),
          namespace: Pundit::Namespace.new(:project)
        )

        policy = context.policy(comment)

        expect(store).to eq({[:project, comment] => policy})
      end
    end
  end
end
