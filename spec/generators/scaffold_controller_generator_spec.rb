# frozen_string_literal: true

require "generator_spec"
require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"

describe Rails::Generators::ScaffoldControllerGenerator, type: :generator do
  destination File.expand_path("../../tmp", __dir__)
  let(:args) { %w[Post --no-helper --skip-template-engine --skip-routes --skip-helpers] }

  before do
    prepare_destination
    # NOTE: Set up the templates directory, similar to Pundit::Railtie
    templates_dir = File.expand_path("../../lib/generators/rails/scaffold_controller/templates", __dir__)
    Rails::Generators::ScaffoldControllerGenerator.source_paths.unshift(templates_dir)

    run_generator(args)
  end

  it "generates a scaffold controller with Pundit integration" do
    assert_file "app/controllers/posts_controller.rb" do |content|
      expect(content).to include("class PostsController < ApplicationController")

      %w[index show new edit create update destroy].each do |action|
        expect(content).to include("def #{action}")
      end

      expect(content).to include("authorize @post")
      expect(content).to include("policy_scope(Post.all)")
    end
  end

  context "when API mode" do
    let(:args) { %w[Post --api --no-helper --skip-template-engine --skip-routes --skip-helpers] }

    it "generates a scaffold API controller with Pundit integration" do
      assert_file "app/controllers/posts_controller.rb" do |content|
        expect(content).to include("class PostsController < ApplicationController")
        expect(content).to include("render json: @posts")

        %w[index show create update destroy].each do |action|
          expect(content).to include("def #{action}")
        end

        expect(content).to include("authorize @post")
        expect(content).to include("policy_scope(Post.all)")
      end
    end
  end
end
