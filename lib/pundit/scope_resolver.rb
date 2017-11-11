module Pundit
  # Finds policy scope class for given object.
  # @api public
  # @example
  #   user = User.find(params[:id])
  #   resolver = PolicyResolver.new(user, Post)
  #   resolver.resolve #=> calls PostPolicy::Scope.new(user, Post).resolve
  #
  #   resolver = PolicyResolver.new(user, [:admin, Post])
  #   resolver.resolve #=> calls Admin::PostPolicy::Scope.new(user, Post).resolve
  #
  class ScopeResolver
    #
    # @param resource_scope [any] the object to find policy and scope classes for
    #     could be a class name like `Post` or an array
    #     to define a namespaced class like `[:admin, Post]`
    # @param user [object] pundit current user
    #
    def initialize(user, resource_scope)
      @user = user
      @resource_scope = resource_scope.respond_to?(:each) ? resource_scope.last : resource_scope
      @policy_class = PolicyFinder.new(resource_scope).policy
    end

    # @return [object] the return value of Policy::Scope#resolve
    #
    def resolve
      scope_class.new(@user, @resource_scope).resolve if scope_class
    end

    # @return [object] the return value of Policy::Scope#resolve
    # @raise [NotDefinedError] if policy scope could not be determined
    #
    def resolve!
      scope_class!.new(@user, @resource_scope).resolve
    end

    private

    def scope_class
      "#{@policy_class}::Scope".safe_constantize
    end

    def scope_class!
      raise NotDefinedError, "unable to find policy scope of nil" if @resource_scope.nil?
      scope_class or raise NotDefinedError, "unable to find Scope class for `#{@policy_class}`"
    end
  end
end