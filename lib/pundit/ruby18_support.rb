# Define Object#public_send for ruby 1.8 backward compatibility
if RUBY_VERSION.to_f < 1.9
  class Object
    def public_send(name, *args)
      unless public_methods.include?(name.to_s)
        raise NoMethodError.new("undefined method `#{name}' for \"#{self.inspect}\":#{self.class}")
      end
      send(name, *args)
    end
  end
end