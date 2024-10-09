# frozen_string_literal: true

class CommentsRelation
  def initialize(empty: false)
    @empty = empty
  end

  def blank?
    @empty
  end

  def self.model_name
    Comment.model_name
  end
end
