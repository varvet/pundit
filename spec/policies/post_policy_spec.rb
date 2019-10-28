# frozen_string_literal: true

require "spec_helper"

describe PostPolicy do
  let(:user) { double }
  let(:own_post) { double(user: user) }
  let(:other_post) { double(user: double) }
  subject { described_class }

  permissions :update?, :show? do
    it "is successful when all permissions match" do
      should permit(user, own_post)
    end

    it "fails when any permissions do not match" do
      expect do
        should permit(user, other_post)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  permissions :custom_action? do
    context "passing in extra values" do
      context "argument is true" do
        it "is successful" do
          should permit(user, own_post, true)
        end
      end
      context "argument is false" do
        it "fails" do
          should_not permit(user, own_post, false)
        end
      end
    end
  end

  permissions :two_arguments? do
    context "both arguments are true" do
      it "is successful" do
        should permit(user, own_post, true, true)
      end
    end
    context "one argument is false" do
      it "fails" do
        should_not permit(user, own_post, true, false)
      end
    end
  end
end
