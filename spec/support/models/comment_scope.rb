# frozen_string_literal: true

class CommentScope
  attr_reader :original_object

  def initialize(original_object)
    @original_object = original_object
  end

  def ==(other)
    original_object == other.original_object
  end
end
