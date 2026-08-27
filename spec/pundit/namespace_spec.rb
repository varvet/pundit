# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pundit::Namespace do
  let(:comment) { Comment.new }

  describe "#wrap" do
    it "leaves the record alone when empty" do
      expect(described_class.new.wrap(comment)).to be(comment)
      expect(described_class.new.wrap([:admin, comment])).to eq([:admin, comment])
    end

    it "wraps a record in the namespace" do
      expect(described_class.new(:project).wrap(comment)).to eq([:project, comment])
    end

    it "wraps an already namespaced record" do
      expect(described_class.new(:project).wrap([:admin, comment])).to eq([:project, :admin, comment])
    end

    it "supports nested namespaces" do
      expect(described_class.new(:project, :admin).wrap(comment)).to eq([:project, :admin, comment])
    end
  end

  describe "#for" do
    it "returns a new namespace, replacing this one" do
      namespace = described_class.new(:project).for(:admin)

      expect(namespace.namespace).to eq([:admin])
    end
  end
end
