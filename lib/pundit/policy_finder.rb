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
      return @policy if defined?(@policy)

      @policy = if object.respond_to?(:policy_class)
        object.policy_class
      elsif object.class.respond_to?(:policy_class)
        object.class.policy_class
      else
        lookup_policy
      end
    end

    def scope!
      scope or raise NotDefinedError, "unable to find scope #{policy}::Scope for #{object}"
    end

    def policy!
      policy or raise NotDefinedError, "unable to find policy #{policy_fqns} for #{object}"
    end

  private
    def object_namespace
      ns = object.class.name.deconstantize
      ns.empty? ? Object : ns.constantize
    end

    def lookup_policy
      policy_fqns.each do |fqn|
        begin
          return fqn.constantize
        rescue NameError
        end
      end

      return nil
    end

    def policy_fqns
      sanitize_fqns(["#{namespace}::#{klass_name}", "#{object_namespace}::#{klass_name}"])
    end

    def sanitize_fqns(fqns)
      fqns.map { |fqn| fqn.gsub(/^Object::/, '') }
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
