# Pundit

[![Build Status](https://secure.travis-ci.org/elabs/pundit.png?branch=master)](https://travis-ci.org/elabs/pundit)

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

## Policies

Pundit is focused around the notion of policy classes. We suggest that you put
these classes in `app/policies`. This is a simple example:

``` ruby
class PostPolicy
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def create?
    user.admin? or not post.published?
  end
end
```

As you can see, this is just a plain Ruby class. As a convenience, we can inherit
from Struct:

``` ruby
class PostPolicy < Struct.new(:user, :post)
  def create?
    user.admin? or not post.published?
  end
end
```

Pundit makes the following assumptions about this class:

- The class has the same name as some kind of model class, only suffixed
  with the word "Policy".
- The first argument is a user. In your controller, Pundit will call the
  `current_user` method to retrieve what to send into this argument
- The second argument is some kind of model object, whose authorization
  you want to check. This does not need to be an ActiveRecord or even
  an ActiveModel object, it can be anything really.
- The class implements some kind of query method, in this case `create?`.
  Usually, this will map to the name of a particular controller action.

That's it really.

Supposing that you have an instance of class `Post`, Pundit now lets you do
this in your controller:

``` ruby
def create
  @post = Post.new(params[:post])
  authorize @post
  if @post.save
    redirect_to @post
  else
    render :new
  end
end
```

The authorize method automatically infers that `Post` will have a matching
`PostPolicy` class, and instantiates this class, handing in the current user
and the given record. It then infers from the action name, that it should call
`create?` on this instance of the policy. In this case, you can imagine that
`authorize` would have done something like this:

``` ruby
raise "not authorized" unless PostPolicy.new(current_user, @post).create?
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
<% if policy(@post).create? %>
  <%= link_to "New post", new_post_path %>
<% end %>
```

## Ensuring policies are used

Pundit adds a method called `verify_authorized` to your controllers. This
method will raise an exception if `authorize` has not yet been called. You
should run this method in an `after_filter` to ensure that you haven't
forgotten to authorize the action. For example:

``` ruby
class ApplicationController < ActionController::Base
  after_filter :verify_authorized, :except => :index
end
```

## Scopes

Often, you will want to have some kind of view listing records which a
particular user has access to. When using Pundit, you are expected to
define a class called a policy scope. It can look something like this:

``` ruby
class PostPolicy < Struct.new(:user, :post)
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        scope.where(:published => true)
      end
    end
  end

  def create?
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
  <p><% link_to @post.title, post_path(post) %></p>
<% end %>
```

## Manually specifying policy classes

Sometimes you might want to explicitly declare which policy to use for a given
class, instead of letting Pundit infer it. This can be done like so:

``` ruby
class Post
  def self.policy_class
    PostablePolicyClass
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

## Manually setting an error message

If you want to customize that error message when you handle `NotAuthorizedError`
exception messages just make sure your policy class responds to `error_message`

``` ruby
class ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'must provide access token' if user.nil?
    @user   = user
    @record = record
  end

  def error_message
    @error_message ||= "User doesn't have access to perform this action"
  end
end
```

# License

Licensed under the MIT license, see the separate LICENSE.txt file.
