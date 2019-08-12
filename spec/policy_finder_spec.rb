# frozen_string_literal: true

require "spec_helper"

describe Pundit::PolicyFinder do
  let(:user) { double }
  let(:post) { Post.new(user) }
  let(:comment) { CommentFourFiveSix.new }
  let(:article) { Article.new }

  describe "#scope" do
    subject { described_class.new(post) }

    it "returns a policy scope" do
      expect(subject.scope).to eq PostPolicy::Scope
    end

    context "policy is nil" do
      it "returns nil" do
        allow(subject).to receive(:policy).and_return nil
        expect(subject.scope).to eq nil
      end
    end
  end

  describe "#policy" do
    subject { described_class.new(post) }

    it "returns a policy" do
      expect(subject.policy).to eq PostPolicy
    end

    context "with a string" do
      it "returns a policy" do
        allow(subject).to receive(:find).and_return "PostPolicy"
        expect(subject.policy).to eq PostPolicy
      end
    end

    context "with a class" do
      it "returns a policy" do
        allow(subject).to receive(:find).and_return PostPolicy
        expect(subject.policy).to eq PostPolicy
      end
    end

    context "with nil" do
      it "returns nil" do
        allow(subject).to receive(:find).and_return nil
        expect(subject.policy).to eq nil
      end
    end

    context "with a string that can't be constantized" do
      it "returns nil" do
        allow(subject).to receive(:find).and_return "FooPolicy"
        expect(subject.policy).to eq nil
      end
    end
  end

  describe "#scope!" do
    context "@object is nil" do
      subject { described_class.new(nil) }

      it "returns the NilClass policy's scope class" do
        expect(subject.scope!).to eq NilClassPolicy::Scope
      end
    end

    context "@object is defined" do
      subject { described_class.new(post) }

      it "returns the scope" do
        expect(subject.scope!).to eq PostPolicy::Scope
      end
    end
  end

  describe "#param_key" do
    context "object responds to model_name" do
      subject { described_class.new(comment) }

      it "returns the param_key" do
        expect(subject.object).to respond_to(:model_name)
        expect(subject.param_key).to eq "comment_four_five_six"
      end
    end

    context "object is a class" do
      subject { described_class.new(Article) }

      it "returns the param_key" do
        expect(subject.object).not_to respond_to(:model_name)
        expect(subject.object).to be_a Class
        expect(subject.param_key).to eq "article"
      end
    end

    context "object is an instance of a class" do
      subject { described_class.new(article) }

      it "returns the param_key" do
        expect(subject.object).not_to respond_to(:model_name)
        expect(subject.object).not_to be_a Class
        expect(subject.object).to be_an_instance_of Article

        expect(subject.param_key).to eq "article"
      end
    end

    context "object is an array" do
      subject { described_class.new([:project, article]) }

      it "returns the param_key for the last element of the array" do
        expect(subject.object).not_to respond_to(:model_name)
        expect(subject.object).not_to be_a Class
        expect(subject.object).to be_an_instance_of Array

        expect(subject.param_key).to eq "article"
      end
    end
  end
end
