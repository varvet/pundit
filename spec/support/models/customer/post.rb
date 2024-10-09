# frozen_string_literal: true

module Customer
  class Post < ::Post
    def model_name
      OpenStruct.new(param_key: "customer_post")
    end

    def self.policy_class
      PostPolicy
    end
  end
end
