# frozen_string_literal: true

class Post
  def initialize(user = nil)
    @user = user
  end

  attr_reader :user

  def self.published
    :published
  end

  def self.read
    :read
  end

  def to_s
    "Post"
  end

  def inspect
    "#<Post>"
  end
end
