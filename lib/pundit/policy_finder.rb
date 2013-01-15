module Pundit
  class PolicyFinder
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def name
      if object.respond_to?(:model_name)
        object.model_name.to_s
      elsif object.class.respond_to?(:model_name)
        object.class.model_name.to_s
      elsif object.is_a?(Class)
        object.to_s
      else
        object.class.to_s
      end
    end

    def scope
      policy.const_get(:Scope) if policy
    end

    def policy
      policy_name.safe_constantize
    end

    def scope!
      scope or raise NotDefinedError, "unable to find scope for #{object}"
    end

    def policy!
      policy or raise NotDefinedError, "unable to find policy #{policy_name} for #{object}"
    end

    def policy_name
      "#{name}Policy"
    end
  end
end
