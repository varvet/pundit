module Pundit
  class PolicyFinder
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def scope
      policy::Scope if policy
    rescue NameError
      nil
    rescue ArgumentError
      # captures <ArgumentError: Anonymous modules have no name to be referenced by>
      # when used with ActiveSupport < 3
      nil
    end

    def policy
      klass = find
      klass = (Object.respond_to?(:constantize) ? klass.constantize : class_from_string(klass)) if klass.is_a?(String)
      klass
    rescue NameError
      nil
    end

    def scope!
      scope or raise NotDefinedError, "unable to find scope #{find}::Scope for #{object}"
    end

    def policy!
      policy or raise NotDefinedError, "unable to find policy #{find} for #{object}"
    end

  private

    def find
      if object.respond_to?(:policy_class)
        object.policy_class
      elsif object.class.respond_to?(:policy_class)
        object.class.policy_class
      else
        klass = if object.respond_to?(:model_name)
          object.model_name
        elsif object.class.respond_to?(:model_name)
          object.class.model_name
        elsif object.is_a?(Class)
          object
        else
          object.class
        end
        "#{klass}Policy"
      end
    end

    unless Object.respond_to?(:constantize)
      def class_from_string(str)
        str.split('::').inject(Object) do |mod, class_name|
          mod.const_get(class_name)
        end
      end
    end
    
  end
end
