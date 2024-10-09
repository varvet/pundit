# frozen_string_literal: true

class CustomCache
  def initialize
    @store = {}
  end

  def to_h
    @store
  end

  def [](key)
    @store[key]
  end

  def []=(key, value)
    @store[key] = value
  end
end
