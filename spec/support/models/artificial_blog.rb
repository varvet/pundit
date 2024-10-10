# frozen_string_literal: true

class ArtificialBlog < Blog
  def self.policy_class
    BlogPolicy
  end
end
