module Pundit
  class ScopeResolver
    attr_reader :policy
    attr_reader :user
    attr_reader :resource_scope

    def initialize(user, resource_scope)
      @user = user
      @resource_scope = resource_scope.respond_to?(:each) ? resource_scope.last : resource_scope
      @policy = PolicyFinder.new(resource_scope).policy
    end

    def resolve
      scope_class.new(user, resource_scope).resolve if scope_class
    end

    def resolve!
      scope_class!.new(user, resource_scope).resolve
    end

  private

    # @return [nil, Scope{#resolve}] scope class which can resolve to a scope
    # @see https://github.com/elabs/pundit#scopes
    # @example
    #   scope = finder.scope #=> UserPolicy::Scope
    #   scope.resolve #=> <#ActiveRecord::Relation ...>
    #
    def scope_class
      policy::Scope if policy
    rescue NameError
      nil
    end

    # @return [Scope{#resolve}] scope class which can resolve to a scope
    # @raise [NotDefinedError] if scope could not be determined
    #
    def scope_class!
      raise NotDefinedError, "unable to find policy scope of nil" if resource_scope.nil?
      scope_class or raise NotDefinedError, "unable to find scope for `#{policy}` policy"
    end
  end

  # Finds policy and scope classes for given object.
  # @api public
  # @example
  #   user = User.find(params[:id])
  #   finder = PolicyFinder.new(user)
  #   finder.policy #=> UserPolicy
  #   finder.scope #=> UserPolicy::Scope
  #
  class PolicyFinder
    attr_reader :object

    # @param object [any] the object to find policy and scope classes for
    #
    def initialize(object)
      @object = object
    end

    # @return [nil, Class] policy class with query methods
    # @see https://github.com/elabs/pundit#policies
    # @example
    #   policy = finder.policy #=> UserPolicy
    #   policy.show? #=> true
    #   policy.update? #=> false
    #
    def policy
      klass = find
      klass = klass.constantize if klass.is_a?(String)
      klass
    rescue NameError
      nil
    end

    # @return [Class] policy class with query methods
    # @raise [NotDefinedError] if policy could not be determined
    #
    def policy!
      raise NotDefinedError, "unable to find policy of nil" if object.nil?
      policy or raise NotDefinedError, "unable to find policy `#{find}` for `#{object.inspect}`"
    end

    # @return [String] the name of the key this object would have in a params hash
    #
    def param_key
      if object.respond_to?(:model_name)
        object.model_name.param_key.to_s
      elsif object.is_a?(Class)
        object.to_s.demodulize.underscore
      else
        object.class.to_s.demodulize.underscore
      end
    end

  private

    def find
      if object.nil?
        nil
      elsif object.respond_to?(:policy_class)
        object.policy_class
      elsif object.class.respond_to?(:policy_class)
        object.class.policy_class
      else
        klass = if object.is_a?(Array)
          object.map { |x| find_class_name(x) }.join("::")
        else
          find_class_name(object)
        end
        "#{klass}#{SUFFIX}"
      end
    end

    def find_class_name(subject)
      if subject.respond_to?(:model_name)
        subject.model_name
      elsif subject.class.respond_to?(:model_name)
        subject.class.model_name
      elsif subject.is_a?(Class)
        subject
      elsif subject.is_a?(Symbol)
        subject.to_s.camelize
      else
        subject.class
      end
    end
  end
end
