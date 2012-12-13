module Pundit
  class PolicyFinder
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def scope
      policy::Scope
    rescue NameError
      nil
    end

    def policy
      klass = policy_evaluator
      klass = klass.constantize if klass.is_a?(String)
      klass
    rescue NameError
      nil
    end

    def scope!
      scope or raise NotDefinedError, "unable to find scope #{scope_name} for #{object}"
    end

    def policy!
      policy or raise NotDefinedError, "unable to find policy #{policy_name} for #{object}"
    end

    private
      def policy_evaluator
        if object.respond_to?(:policy_class)
          return object.policy_class
        elsif object.class.respond_to?(:policy_class)
          return object.class.policy_class
        elsif object.respond_to?(:model_name)
          klass = object.model_name
        elsif object.class.respond_to?(:model_name)
          klass = object.class.model_name
        elsif object.is_a?(Class)
          klass = object
        else
          klass = object.class
        end

        "#{klass}Policy"
      end

      def scope_name
        "#{policy_name}::Scope"
      end

      def policy_name
        name = policy_evaluator
        return name.name unless name.is_a?(String)
        name
      end
  end
end
