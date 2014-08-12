module Pundit
  class PolicyFinder
    attr_reader :object, :namespace

    def initialize(object, namespace = Object)
      @object = object
      @namespace = namespace
    end

    def scope
      policy::Scope if policy
    rescue NameError
      nil
    end

    def policy
      if object.respond_to?(:policy_class)
        object.policy_class
      elsif object.class.respond_to?(:policy_class)
        object.class.policy_class
      else
        begin
          policy_in_namespace(namespace)
        rescue NameError
          policy_in_namespace(object_namespace)
        end
      end
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

    def policy_in_namespace(namespace)
      "#{namespace}::#{klass_name}".constantize
    end

    def object_namespace
      ns = object.class.name.deconstantize
      ns.empty? ? Object : ns.constantize
    end

    def klass_name
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
      "#{klass}Policy".demodulize
    end
  end
end
