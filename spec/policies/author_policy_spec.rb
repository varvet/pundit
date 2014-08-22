require "spec_helper"

describe AuthorPolicy do
  let(:user) { double(:user, email: "kelly@slater.com") }
  let(:author) { double(:author, email: "kelly@slater.com") }
  let(:website) { double(:website, owner: user) }
  let(:other_website) { double(:website, owner: double(:other_user)) }
  subject { AuthorPolicy }

  permissions :update? do
    it "is successful when the permissions of all arguments match" do
      should permit(user, author, website)
    end

    it "fails when any permissions of any args do not match" do
      should_not permit(user, author, other_website)
    end
  end
end
