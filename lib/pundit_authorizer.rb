# This is a stand alone authorizer without any
# dependency on controller.
#
# It is very useful on service object.
#
# Example usage:
#
#   authorizer = PunditAuthorizer.new(user, post)
#   authorizer.authorize_on 'create'
#
# Example on a service object
#
#   class PostCreator
#     attr_reader :user, :post
#     def initialize(user, params)
#       @user = user
#       @post = Post.new(params)
#     end
#
#     def create
#       authorize_post
#       save_post
#       process_things_after_save
#     end
#
#     def authorize_post
#       authorizer = PunditAuthorizer.new(user, post)
#       authorizer.authorize_on 'create'
#     end
class PunditAuthorizer
  include Pundit

  attr_reader :user, :obj

  def initialize(user, obj)
    @user = user
    @obj  = obj
  end

  # The only API
  # query can end with '? optionally
  def authorize_on(query)
    query += '?' unless query.last == '?'
    authorize(obj, query)
  end

  private
  # Override Pundit to refer user to @user, instead of current_user
  def pundit_user
    user
  end
end
