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
      return object.policy_class if object.respond_to?(:policy_class)
      return object.class.policy_class if object.class.respond_to?(:policy_class)
      return "#{model_name}Policy"
    end

    def model_name
      return object.model_name if object.respond_to?(:model_name)
      return object.class.model_name if object.class.respond_to?(:model_name)
      return object if object.is_a?(Class)
      return object.class
    end

  end
end
