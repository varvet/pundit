# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pundit RSpec DSL" do
  include Pundit::RSpec::PolicyExampleGroup

  let(:fake_rspec) do
    double = class_double(RSpec::ExampleGroups)
    double.extend(::Pundit::RSpec::DSL)
    double
  end
  let(:block) { proc { "block content" } }

  let(:user) { double }
  let(:other_user) { double }
  let(:post) { Post.new(user) }
  let(:policy) { PostPolicy }

  it "calls describe with the correct metadata and without :focus" do
    expected_metadata = { permissions: %i[item1 item2], caller: instance_of(Array) }
    expect(fake_rspec).to receive(:describe).with("item1 and item2", match(expected_metadata)) do |&block|
      expect(block.call).to eq("block content")
    end

    fake_rspec.permissions(:item1, :item2, &block)
  end

  it "calls describe with the correct metadata and with :focus" do
    expected_metadata = { permissions: %i[item1 item2], caller: instance_of(Array), focus: true }
    expect(fake_rspec).to receive(:describe).with("item1 and item2", match(expected_metadata)) do |&block|
      expect(block.call).to eq("block content")
    end

    fake_rspec.permissions(:item1, :item2, :focus, &block)
  end

  describe "#permit" do
    context "when not appropriately wrapped in permissions" do
      it "raises a descriptive error" do
        expect do
          expect(policy).to permit(user, post)
        end.to raise_error(KeyError, <<~MSG.strip)
          No permissions in example metadata, did you forget to wrap with `permissions :show?, ...`?
        MSG
      end
    end

    permissions :edit?, :update? do
      it "succeeds when action is permitted" do
        expect(policy).to permit(user, post)
      end

      context "when it fails" do
        it "fails with a descriptive error message" do
          expect do
            expect(policy).to permit(other_user, post)
          end.to raise_error(RSpec::Expectations::ExpectationNotMetError, <<~MSG.strip)
            Expected PostPolicy to grant edit? and update? on Post but edit? and update? were not granted
          MSG
        end
      end

      context "when negated" do
        it "succeeds when action is not permitted" do
          expect(policy).not_to permit(other_user, post)
        end

        context "when it fails" do
          it "fails with a descriptive error message" do
            expect do
              expect(policy).not_to permit(user, post)
            end.to raise_error(RSpec::Expectations::ExpectationNotMetError, <<~MSG.strip)
              Expected PostPolicy not to grant edit? and update? on Post but edit? and update? were granted
            MSG
          end
        end
      end
    end
  end
end
