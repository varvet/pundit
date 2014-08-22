require "active_support/core_ext/kernel"

warnings = capture(:stderr) do
  require "pundit"
  require "pundit/rspec"
end

unless warnings.to_s.empty?
  puts "ERROR: Encountered deprecation warning!"
  puts warnings
  exit 1
end

require "pry"
require "active_support/core_ext"
require "active_model/naming"

I18n.enforce_available_locales = false

module PunditSpecHelper
  extend RSpec::Matchers::DSL

  matcher :be_truthy do
    match do |actual|
      actual
    end
  end
end

RSpec.configure do |config|
  config.include PunditSpecHelper
end

class PostPolicy < Struct.new(:user, :post)
  def update?
    post.user == user
  end
  def destroy?
    false
  end
  def show?
    true
  end
end
class PostPolicy::Scope < Struct.new(:user, :scope)
  def resolve
    scope.published
  end
end
class Post < Struct.new(:user)
  def self.published
    :published
  end
end

class CommentPolicy < Struct.new(:user, :comment); end
class CommentPolicy::Scope < Struct.new(:user, :scope)
  def resolve
    scope
  end
end
class Comment; extend ActiveModel::Naming; end

class Article; end

class BlogPolicy < Struct.new(:user, :blog); end
class Blog; end
class ArtificialBlog < Blog
  def self.policy_class
    BlogPolicy
  end
end
class ArticleTag
  def self.policy_class
    Struct.new(:user, :tag) do
      def show?
        true
      end
      def destroy?
        false
      end
    end
  end
end

class DashboardPolicy < Struct.new(:user, :dashboard); end

class Controller
  include Pundit

  attr_reader :current_user, :params

  def initialize(current_user, params)
    @current_user = current_user
    @params = params
  end
end
