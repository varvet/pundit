module Pundit
  # Finds policy and scope classes for given object.
  # Allows caller to define multiple policies for the same
  # object.  For example, if a business implements two entirely
  # different workflows for the same model, two seperate policies
  # Can be created to manage each workflow.
  # @api public
  # @example

  # WorkflowOne without namespace
  #   user = User.find(params[:id])
  #   finder = PrefixPolicyFinder.new(user, '')
  #   finder.policy #=> UserPolicy
  #   finder.scope #=> UserPolicy::Scope
  #

  # Workflow Two with namespace
  #   user = User.find(params[:id])
  #   finder = PrefixPolicyFinder.new(user, 'WorkflowOne::')
  #   finder.policy #=> WorkflowOne::UserPolicy
  #   finder.scope #=> WorkflowOne::UserPolicy::Scope
  class PrefixPolicyFinder < PolicyFinder
    attr_reader :prefix

    def initialize(object, prefix)
      super(object)
      @prefix = prefix
    end

    private
    def find
      return "#{prefix}#{super.to_s}"
    end
  end
end