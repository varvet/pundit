class ClosedPolicy
  attr_reader :context, :resource, :user
  alias_method :scope, :resource # for when the policy is initialised with a scope to be resolved 

  def initialize(context, resource=nil, user=nil)
    @context = context
    @user = user || context.current_user

    raise Pundit::NotAuthorizedError unless @user

    @resource = resource || context.resource
  end

  def resolve
    scope
  end

  def index?
    read?
  end

  def show?
    read?
  end

  def read?
    false
  end

  def create?
    update?
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end
end
