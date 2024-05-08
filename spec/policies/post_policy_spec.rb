# frozen_string_literal: true

require "spec_helper"

RSpec.describe PostPolicy do
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

    it "uses the default description if not overridden" do
      expect(permit(user, own_post).description).to eq("permit #{user.inspect} and #{own_post.inspect}")
    end

    context "when the matcher description is overridden" do
      after do
        Pundit::RSpec::Matchers.description = nil
      end

      it "sets a custom matcher description with a Proc" do
        allow(user).to receive(:role).and_return("default_role")
        allow(own_post).to receive(:id).and_return(1)

        Pundit::RSpec::Matchers.description = lambda { |user, record|
          "permit user with role #{user.role} to access record with ID #{record.id}"
        }

        description = permit(user, own_post).description
        expect(description).to eq("permit user with role default_role to access record with ID 1")
      end

      it "sets a custom matcher description with a string" do
        Pundit::RSpec::Matchers.description = "permit user"
        expect(permit(user, own_post).description).to eq("permit user")
      end
    end
  end
end
