# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

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

  describe "scaffold controller hook" do
    before(:all) do
      require "pundit/scaffold_hook"
      Pundit::ScaffoldHook.install
    end

    it "adds --policy option to scaffold controller generator" do
      expect(Rails::Generators::ScaffoldControllerGenerator.class_options).to have_key(:policy)
    end

    it "defaults to generating a policy" do
      expect(Rails::Generators::ScaffoldControllerGenerator.class_options[:policy].default).to be true
    end

    it "generates policy when scaffold runs" do
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          Pundit::Generators::InstallGenerator.new([], {quiet: true}).invoke_all

          generator = Rails::Generators::ScaffoldControllerGenerator.new(%w[Article], {quiet: true, policy: true, orm: false, template_engine: false, helper: false, test_framework: false, resource_route: false})
          generator.generate_pundit_policy

          expect(File.exist?("app/policies/article_policy.rb")).to be true
        end
      end
    end

    it "skips policy generation with --no-policy" do
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          generator = Rails::Generators::ScaffoldControllerGenerator.new(%w[Article], {quiet: true, policy: false, orm: false, template_engine: false, helper: false, test_framework: false, resource_route: false})
          generator.generate_pundit_policy

          expect(File.exist?("app/policies/article_policy.rb")).to be false
        end
      end
    end
  end
end
