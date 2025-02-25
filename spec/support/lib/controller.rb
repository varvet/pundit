# frozen_string_literal: true

class Controller
  attr_accessor :current_user
  attr_reader :action_name, :params

  class View
    def initialize(controller)
      @controller = controller
    end

    attr_reader :controller
  end

  class << self
    def helper(mod)
      View.include(mod)
    end

    def helper_method(method)
      View.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args, **kwargs, &block)
          controller.send(:#{method}, *args, **kwargs, &block)
        end
      RUBY
    end
  end

  include Pundit::Authorization
  # Mark protected methods public so they may be called in test
  public(*Pundit::Authorization.protected_instance_methods)

  def initialize(current_user, action_name, params)
    @current_user = current_user
    @action_name = action_name
    @params = params
  end
end
