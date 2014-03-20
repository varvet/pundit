require "pundit"
require "pry"
require "active_support/core_ext"
require "active_model/naming"
require 'spec_helper'

describe 'Pundit with ActiveSupport' do
  module AS ; end
  class AS::PostPolicy < Struct.new(:user, :post)
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
  class AS::PostPolicy::Scope < Struct.new(:user, :scope)
    def resolve
      scope.published
    end
  end
  class AS::Post < Struct.new(:user)
    def self.published
      :published
    end
  end

  class AS::CommentPolicy < Struct.new(:user, :comment); end
  class AS::CommentPolicy::Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
  class AS::Comment; extend ActiveModel::Naming; end

  class AS::Article; end

  class AS::BlogPolicy < Struct.new(:user, :blog); end
  class AS::Blog; end
  class AS::ArtificialBlog < AS::Blog
    def self.policy_class
      AS::BlogPolicy
    end
  end
  class AS::ArticleTag
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

  SpecHelper.pundit_examples(self, AS)
end
