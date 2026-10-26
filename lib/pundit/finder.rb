# frozen_string_literal: true

module Pundit
  # Finds policy and scope classes for records on behalf of a {Pundit::Context}.
  #
  # Delegates to {Pundit::PolicyFinder}. Pass any object answering #policy and
  # #scope to a context instead, with or without wrapping this one. The
  # methods are independent, so changing #policy does not change #scope.
  #
  # @example Always use one policy for posts
  #   class SpecialFinder
  #     def initialize(finder = Pundit::Finder.new) = @finder = finder
  #
  #     def policy(record)
  #       record.is_a?(Post) ? SpecialPostPolicy : @finder.policy(record)
  #     end
  #
  #     def scope(record) = @finder.scope(record)
  #   end
  #
  #   Pundit::Context.new(user: current_user, finder: SpecialFinder.new)
  #
  # @see Pundit::Context#with
  # @since v2.6.0
  class Finder
    # @param record [Object, Array] a possibly namespaced record
    # @return [Class, nil] policy class with query methods
    # @since v2.6.0
    def policy(record)
      PolicyFinder.new(record).policy
    end

    # @param record [Object, Array] a possibly namespaced record
    # @return [Class, nil] scope class which can resolve to a scope
    # @since v2.6.0
    def scope(record)
      PolicyFinder.new(record).scope
    end
  end
end
