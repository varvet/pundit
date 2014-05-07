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
    end

    def policy
      klass = find
      klass = klass.constantize if klass.is_a?(String)
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
      if policy_class_defined?(object)
        object.policy_class
      elsif policy_class_defined?(object.class)
        object.class.policy_class
      else
        "#{class_name_for_policy}Policy"
      end
    end

    def class_name_for_policy
      if model_name_defined?(object)
        object.model_name
      elsif model_name_defined?(object.class)
        object.class.model_name
      elsif object.is_a?(Class)
        object
      else
        object.class
      end
    end

    def policy_class_defined?(object_to_check)
      object_to_check.public_methods.include?(:policy_class)
    end

    def model_name_defined?(object_to_check)
      object_to_check.public_methods.include?(:model_name)
    end
  end
end
