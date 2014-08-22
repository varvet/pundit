# Pundit

[![Build Status](https://secure.travis-ci.org/elabs/pundit.png?branch=master)](https://travis-ci.org/elabs/pundit)
[![Code Climate](https://codeclimate.com/github/elabs/pundit.png)](https://codeclimate.com/github/elabs/pundit)
[![Inline docs](http://inch-ci.org/github/elabs/pundit.png)](http://inch-ci.org/github/elabs/pundit)

Pundit provides a set of helpers which guide you in leveraging regular Ruby
classes and object oriented design patterns to build a simple, robust and
scaleable authorization system.

## Installation

``` ruby
gem "pundit"
```

Include Pundit in your application controller:

``` ruby
class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
end
```

Optionally, you can run the generator, which will set up an application policy
with some useful defaults for you:

``` sh
rails g pundit:install
```

After generating your application policy, restart the Rails server so that Rails
can pick up any classes in the new `app/policies/` directory.

## Policies

Pundit is focused around the notion of policy classes. We suggest that you put
these classes in `app/policies`. This is a simple example that allows updating
a post if the user is an admin, or if the post is unpublished:

``` ruby
class PostPolicy
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def update?
    user.admin? or not post.published?
  end
end
```

As you can see, this is just a plain Ruby class. Pundit makes the following
assumptions about this class:

- The class has the same name as some kind of model class, only suffixed
  with the word "Policy".
- The first argument is a user. In your controller, Pundit will call the
  `current_user` method to retrieve what to send into this argument
- The second argument is some kind of model object, whose authorization
  you want to check. This does not need to be an ActiveRecord or even
  an ActiveModel object, it can be anything really.
- The class implements some kind of query method, in this case `update?`.
  Usually, this will map to the name of a particular controller action.

That's it really.

Usually you'll want to inherit from the application policy created by the
generator, or set up your own base class to inherit from:

``` ruby
class PostPolicy < ApplicationPolicy
  def update?
    user.admin? or not post.published?
  end
end
```

Supposing that you have an instance of class `Post`, Pundit now lets you do
this in your controller:

``` ruby
def update
  @post = Post.find(params[:id])
  authorize @post
  if @post.update(post_params)
    redirect_to @post
  else
    render :edit
  end
end
```

The authorize method automatically infers that `Post` will have a matching
`PostPolicy` class, and instantiates this class, handing in the current user
and the given record. It then infers from the action name, that it should call
`update?` on this instance of the policy. In this case, you can imagine that
`authorize` would have done something like this:

``` ruby
raise "not authorized" unless PostPolicy.new(current_user, @post).update?
```

You can pass a second argument to `authorize` if the name of the permission you
want to check doesn't match the action name. For example:

``` ruby
def publish
  @post = Post.find(params[:id])
  authorize @post, :update?
  @post.publish!
  redirect_to @post
end
```

You can easily get a hold of an instance of the policy through the `policy`
method in both the view and controller. This is especially useful for
conditionally showing links or buttons in the view:

``` erb
<% if policy(@post).update? %>
  <%= link_to "Edit post", edit_post_path(@post) %>
<% end %>
```
## Headless policies

Given there is a policy without a corresponding model / ruby class,
you can retrieve it by passing a symbol.

```ruby
# app/policies/dashboard_policy.rb
class DashboardPolicy < Struct.new(:user, :dashboard)
  # ...
end

# In controllers
authorize :dashboard, :show?

# In views
<% if policy(:dashboard).show? %>
  <%= link_to 'Dashboard', dashboard_path %>
<% end %>
```

## Ensuring policies are used

Pundit adds a method called `verify_authorized` to your controllers. This
method will raise an exception if `authorize` has not yet been called. You
should run this method in an `after_action` to ensure that you haven't
forgotten to authorize the action. For example:

``` ruby
class ApplicationController < ActionController::Base
  after_action :verify_authorized, :except => :index
end
```

Likewise, Pundit also adds `verify_policy_scoped` to your controller.  This
will raise an exception in the vein of `verify_authorized`.  However it tracks
if `policy_scope` is used instead of `authorize`.  This is mostly useful for
controller actions like `index` which find collections with a scope and don't
authorize individual instances.

``` ruby
class ApplicationController < ActionController::Base
  after_action :verify_policy_scoped, :only => :index
end
```

## Scopes

Often, you will want to have some kind of view listing records which a
particular user has access to. When using Pundit, you are expected to
define a class called a policy scope. It can look something like this:

``` ruby
class PostPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.where(:published => true)
      end
    end
  end

  def update?
    user.admin? or not post.published?
  end
end
```

Pundit makes the following assumptions about this class:

- The class has the name `Scope` and is nested under the policy class.
- The first argument is a user. In your controller, Pundit will call the
  `current_user` method to retrieve what to send into this argument.
- The second argument is a scope of some kind on which to perform some kind of
  query. It will usually be an ActiveRecord class or a
  `ActiveRecord::Relation`, but it could be something else entirely.
- Instances of this class respond to the method `resolve`, which should return
  some kind of result which can be iterated over. For ActiveRecord classes,
  this would usually be an `ActiveRecord::Relation`.

You'll probably want to inherit from the application policy scope generated by the
generator, or create your own base class to inherit from:

``` ruby
class PostPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(:published => true)
      end
    end
  end

  def update?
    user.admin? or not post.published?
  end
end
```

You can now use this class from your controller via the `policy_scope` method:

``` ruby
def index
  @posts = policy_scope(Post)
end
```

Just as with your policy, this will automatically infer that you want to use
the `PostPolicy::Scope` class, it will instantiate this class and call
`resolve` on the instance. In this case it is a shortcut for doing:

``` ruby
def index
  @posts = PostPolicy::Scope.new(current_user, Post).resolve
end
```

You can, and are encouraged to, use this method in views:

``` erb
<% policy_scope(@user.posts).each do |post| %>
  <p><%= link_to post.title, post_path(post) %></p>
<% end %>
```

## Manually specifying policy classes

Sometimes you might want to explicitly declare which policy to use for a given
class, instead of letting Pundit infer it. This can be done like so:

``` ruby
class Post
  def self.policy_class
    PostablePolicy
  end
end
```

## Just plain old Ruby

As you can see, Pundit doesn't do anything you couldn't have easily done
yourself.  It's a very small library, it just provides a few neat helpers.
Together these give you the power of building a well structured, fully working
authorization system without using any special DSLs or funky syntax or
anything.

Remember that all of the policy and scope classes are just plain Ruby classes,
which means you can use the same mechanisms you always use to DRY things up.
Encapsulate a set of permissions into a module and include them in multiple
policies. Use `alias_method` to make some permissions behave the same as
others. Inherit from a base set of permissions. Use metaprogramming if you
really have to.

## Generator

Use the supplied generator to generate policies:

``` sh
rails g pundit:policy post
```

## Closed systems

In many applications, only logged in users are really able to do anything. If
you're building such a system, it can be kind of cumbersome to check that the
user in a policy isn't `nil` for every single permission.

We suggest that you define a filter that redirects unauthenticated users to the
login page. As a secondary defence, if you've defined an ApplicationPolicy, it
might be a good idea to raise an exception if somehow an unauthenticated user
got through. This way you can fail more gracefully.

``` ruby
class ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end
end
```

## Rescuing a denied Authorization in Rails

Pundit raises a `Pundit::NotAuthorizedError` you can
[rescue_from](http://guides.rubyonrails.org/action_controller_overview.html#rescue-from)
in your `ApplicationController`. You can customize the `user_not_authorized`
method in every controller.

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
```

### Creating custom error messages

`NotAuthorizedError`s provide information on what query (e.g. `:create?`), what
record (e.g. an instance of `Post`), and what policy (e.g. an instance of
`PostPolicy`) caused the error to be raised.

One way to use these `query`, `record`, and `policy` properties is to connect
them with `I18n` to generate error messages. Here's how you might go about doing
that.

```ruby
class ApplicationController < ActionController::Base
 rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

 private

 def user_not_authorized(exception)
   policy_name = exception.policy.class.to_s.underscore

   flash[:error] = I18n.t "pundit.#{policy_name}.#{exception.query}",
     default: 'You cannot perform this action.'
   redirect_to(request.referrer || root_path)
 end
end
```

```yaml
en:
 pundit:
   post_policy:
     update?: 'You cannot edit this post!'
     create?: 'You cannot create posts!'
```

Of course, this is just an example. Pundit is agnostic as to how you implement
your error messaging.

## Manually retrieving policies and scopes

Sometimes you want to retrieve a policy for a record outside the controller or
view. For example when you delegate permissions from one policy to another.

You can easily retrieve policies and scopes like this:

``` ruby
Pundit.policy!(user, post)
Pundit.policy(user, post)

Pundit.policy_scope!(user, Post)
Pundit.policy_scope(user, Post)
```

The bang methods will raise an exception if the policy does not exist, whereas
those without the bang will return nil.

## Customize Pundit user

In some cases your controller might not have access to `current_user`, or your
`current_user` is not the method that should be invoked by Pundit. Simply
define a method in your controller called `pundit_user`.

```ruby
def pundit_user
  User.find_by_other_means
end
```

## Strong parameters

In Rails 4 (or Rails 3.2 with the
[strong_parameters](https://github.com/rails/strong_parameters) gem),
mass-assignment protection is handled in the controller.
Pundit helps you permit different users to set different attributes. Don't
forget to provide your policy an instance of object or a class so correct
permissions could be loaded.

```ruby
# app/policies/post_policy.rb
class PostPolicy < ApplicationPolicy
  def permitted_attributes
    if user.admin? || user.owner_of?(post)
      [:title, :body, :tag_list]
    else
      [:tag_list]
    end
  end
end

# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end

  private

  def post_params
    params.require(:post).permit(*policy(@post || Post).permitted_attributes)
  end
end
```

## RSpec

### Policy Specs

Pundit includes a mini-DSL for writing expressive tests for your policies in RSpec.
Require `pundit/rspec` in your `spec_helper.rb`:

``` ruby
require "pundit/rspec"
```

Then put your policy specs in `spec/policies`, and make them look somewhat like this:

``` ruby
describe PostPolicy do
  subject { PostPolicy }

  permissions :update? do
    it "denies access if post is published" do
      expect(subject).not_to permit(User.new(:admin => false), Post.new(:published => true))
    end

    it "grants access if post is published and user is an admin" do
      expect(subject).to permit(User.new(:admin => true), Post.new(:published => true))
    end

    it "grants access if post is unpublished" do
      expect(subject).to permit(User.new(:admin => false), Post.new(:published => false))
    end
  end
end
```

An alternative approach to Pundit policy specs is scoping them to a user context as outlined in this
[excellent post](http://thunderboltlabs.com/blog/2013/03/27/testing-pundit-policies-with-rspec/).

### View Specs

When writing view specs, you'll notice that the policy helper is not available
and views under test that use it will fail. Thankfully, it's very easy to stub
out the policy to have it return whatever is appropriate for the spec.

``` ruby
describe "users/show" do
  before(:each) do
    user = assign(:user, build_stubbed(:user))
    controller.stub(:current_user).and_return user
  end

  it "renders the destroy action" do
    allow(view).to receive(:policy).and_return double(edit?: false, destroy?: true)

    render
    expect(rendered).to match 'Destroy'
  end
end
```

This technique enables easy unit testing of tricky conditionaly view logic
based on what is or is not authorized.

# External Resources

- [RailsApps Example Application: Pundit and Devise](https://github.com/RailsApps/rails-devise-pundit)
- [Migrating to Pundit from CanCan](http://blog.carbonfive.com/2013/10/21/migrating-to-pundit-from-cancan/)
- [Testing Pundit Policies with RSpec](http://thunderboltlabs.com/blog/2013/03/27/testing-pundit-policies-with-rspec/)
- [Using Pundit outside of a Rails controller](https://github.com/elabs/pundit/pull/136)

# License

Licensed under the MIT license, see the separate LICENSE.txt file.
