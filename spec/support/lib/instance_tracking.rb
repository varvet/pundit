# frozen_string_literal: true

module InstanceTracking
  module ClassMethods
    def instances
      @instances || 0
    end

    attr_writer :instances
  end

  def self.prepended(other)
    other.extend(ClassMethods)
  end

  def initialize(*args, **kwargs, &block)
    self.class.instances += 1
    super(*args, **kwargs, &block)
  end
end
