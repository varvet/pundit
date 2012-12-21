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
      policy_ancestor_names.reduce(nil) do |memo, pan|
        begin
          memo || "#{pan}::Scope".constantize
        rescue NameError
          nil
        end
      end
    end

    def policy
      policy_name.constantize
    rescue NameError
      nil
    end

    def scope!
      scope or raise NotDefinedError, "unable to find scope #{scope_name} for #{object}"
    end

    def policy!
      policy or raise NotDefinedError, "unable to find policy #{policy_name} for #{object}"
    end

    def scope_name
      "#{name}Policy::Scope"
    end

    def policy_name
      "#{name}Policy"
    end

    def policy_ancestor_names
      if policy.present?
        policy.ancestors.map(&:name).select{ |s| s =~ /Policy$/ }
      else
        [policy_name]
      end
    end
  end
end
