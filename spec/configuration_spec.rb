require "spec_helper"

describe Pundit::Configuration do
  let(:configuration) { described_class.new }

  describe "#suffix" do
    it "returns the assigned suffix" do
      configuration.suffix = "Suffix"
      expect(configuration.suffix).to eql "Suffix"
    end

    it "assigns and returns `Policy` as the suffix if one wasn't already assigned" do
      expect(configuration.suffix).to eql "Policy"
    end
  end
end
