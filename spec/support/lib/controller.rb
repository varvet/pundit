# frozen_string_literal: true

class Controller
  include Pundit::Authorization
  # Mark protected methods public so they may be called in test
  # rubocop:disable Style/AccessModifierDeclarations
  public(*Pundit::Authorization.protected_instance_methods)
  # rubocop:enable Style/AccessModifierDeclarations

  attr_reader :current_user, :action_name, :params

  def initialize(current_user, action_name, params)
    @current_user = current_user
    @action_name = action_name
    @params = params
  end
end
