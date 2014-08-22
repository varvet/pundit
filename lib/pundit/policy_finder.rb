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
        elsif object.is_a?(Symbol)
          object.to_s.classify
        else
          object.class
        end
        "#{klass}Policy"
      end
    end
  end
end
