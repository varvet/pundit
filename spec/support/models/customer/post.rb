# frozen_string_literal: true

module Customer
  class Post < ::Post
    extend ActiveModel::Naming

    def self.policy_class
      PostPolicy
    end
  end
end
