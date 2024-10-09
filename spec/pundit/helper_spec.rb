# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pundit::Helper do
  let(:user) { double }
  let(:controller) { Controller.new(user, "update", double) }
  let(:view) { Controller::View.new(controller) }

  describe "#policy_scope" do
    it "doesn't flip pundit_policy_scoped?" do
      scoped = view.policy_scope(Post)

      expect(scoped).to be(Post.published)
      expect(controller).not_to be_pundit_policy_scoped
    end
  end
end
