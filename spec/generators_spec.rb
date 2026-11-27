# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

require "action_dispatch"
require "rails/generators"
require "generators/pundit/install/install_generator"
require "generators/pundit/policy/policy_generator"

RSpec.describe "generators" do
  before(:all) do
    @tmpdir = Dir.mktmpdir

    Dir.chdir(@tmpdir) do
      Pundit::Generators::InstallGenerator.new([], {quiet: true}).invoke_all
      Pundit::Generators::PolicyGenerator.new(%w[Widget], {quiet: true}).invoke_all

      require "./app/policies/application_policy"
      require "./app/policies/widget_policy"
    end
  end

  after(:all) do
    FileUtils.remove_entry(@tmpdir)
  end

  describe "WidgetPolicy", type: :policy do
    permissions :index?, :show?, :create?, :new?, :update?, :edit?, :destroy? do
      it "has safe defaults" do
        expect(WidgetPolicy).not_to permit(double("User"), double("Widget"))
      end
    end

    describe "WidgetPolicy::Scope" do
      describe "#resolve" do
        it "raises a descriptive error" do
          scope = WidgetPolicy::Scope.new(double("User"), double("User.all"))
          expect { scope.resolve }.to raise_error(NoMethodError, /WidgetPolicy::Scope/)
        end
      end
    end
  end

  describe "scaffold_controller integration" do
    before(:all) do
      require "pundit/scaffold_policy"
      Pundit::ScaffoldPolicy.install
    end

    def scaffold(*args)
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.mkdir_p("config")
          File.write("config/routes.rb", "Rails.application.routes.draw {}\n")
          Rails::Generators.invoke("scaffold_controller", ["Article", *args, "--quiet", "--skip-collision-check"])
          yield dir
        end
      end
    end

    it "generates a policy alongside the controller" do
      scaffold do
        expect(File).to exist("app/policies/article_policy.rb")
        expect(File).to exist("app/controllers/articles_controller.rb")
      end
    end

    it "does not alter the generated controller" do
      scaffold do
        expect(File.read("app/controllers/articles_controller.rb")).not_to match(/authorize|policy_scope/)
      end
    end

    it "skips the policy with --no-policy" do
      scaffold("--no-policy") do
        expect(File).not_to exist("app/policies/article_policy.rb")
        expect(File).to exist("app/controllers/articles_controller.rb")
      end
    end
  end
end
