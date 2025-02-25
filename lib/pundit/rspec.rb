# frozen_string_literal: true

# Array#to_sentence
require "active_support/core_ext/array/conversions"

module Pundit
  # Namespace for Pundit's RSpec integration.
  module RSpec
    # Namespace for Pundit's RSpec matchers.
    module Matchers
      extend ::RSpec::Matchers::DSL

      # @!method description=(description)
      class << self
        # Used to build a suitable description for the Pundit `permit` matcher.
        # @api public
        # @param value [String, Proc]
        # @example
        #   Pundit::RSpec::Matchers.description = ->(user, record) do
        #     "permit user with role #{user.role} to access record with ID #{record.id}"
        #   end
        attr_writer :description

        # Used to retrieve a suitable description for the Pundit `permit` matcher.
        # @api private
        # @private
        def description(user, record)
          return @description.call(user, record) if defined?(@description) && @description.respond_to?(:call)

          @description
        end
      end

      # rubocop:disable Metrics/BlockLength
      matcher :permit do |user, record|
        match_proc = lambda do |policy|
          @violating_permissions = permissions.find_all do |permission|
            !policy.new(user, record).public_send(permission)
          end
          @violating_permissions.empty?
        end

        match_when_negated_proc = lambda do |policy|
          @violating_permissions = permissions.find_all do |permission|
            policy.new(user, record).public_send(permission)
          end
          @violating_permissions.empty?
        end

        failure_message_proc = lambda do |policy|
          "Expected #{policy} to grant #{permissions.to_sentence} on " \
          "#{record} but #{@violating_permissions.to_sentence} #{was_or_were} not granted"
        end

        failure_message_when_negated_proc = lambda do |policy|
          "Expected #{policy} not to grant #{permissions.to_sentence} on " \
          "#{record} but #{@violating_permissions.to_sentence} #{was_or_were} granted"
        end

        def was_or_were
          if @violating_permissions.count > 1
            "were"
          else
            "was"
          end
        end

        description do
          Pundit::RSpec::Matchers.description(user, record) || super()
        end

        if respond_to?(:match_when_negated)
          match(&match_proc)
          match_when_negated(&match_when_negated_proc)
          failure_message(&failure_message_proc)
          failure_message_when_negated(&failure_message_when_negated_proc)
        else
          # :nocov:
          # Compatibility with RSpec < 3.0, released 2014-06-01.
          match_for_should(&match_proc)
          match_for_should_not(&match_when_negated_proc)
          failure_message_for_should(&failure_message_proc)
          failure_message_for_should_not(&failure_message_when_negated_proc)
          # :nocov:
        end

        if ::RSpec.respond_to?(:current_example)
          def current_example
            ::RSpec.current_example
          end
        else
          # :nocov:
          # Compatibility with RSpec < 3.0, released 2014-06-01.
          def current_example
            example
          end
          # :nocov:
        end

        def permissions
          current_example.metadata.fetch(:permissions) do
            raise KeyError, <<~ERROR.strip
              No permissions in example metadata, did you forget to wrap with `permissions :show?, ...`?
            ERROR
          end
        end
      end
      # rubocop:enable Metrics/BlockLength
    end

    # Mixed in to all policy example groups to provide a DSL.
    module DSL
      # @example
      #   describe PostPolicy do
      #     permissions :show?, :update? do
      #       it { is_expected.to permit(user, own_post) }
      #     end
      #   end
      #
      # @example focused example group
      #   describe PostPolicy do
      #     permissions :show?, :update?, :focus do
      #       it { is_expected.to permit(user, own_post) }
      #     end
      #   end
      #
      # @param list [Symbol, Array<Symbol>] a permission to describe
      # @return [void]
      def permissions(*list, &block)
        metadata = { permissions: list, caller: caller }

        if list.last == :focus
          list.pop
          metadata[:focus] = true
        end

        description = list.to_sentence
        describe(description, metadata) { instance_eval(&block) }
      end
    end

    # Mixed in to all policy example groups.
    #
    # @private not useful
    module PolicyExampleGroup
      include Pundit::RSpec::Matchers

      def self.included(base)
        base.metadata[:type] = :policy
        base.extend Pundit::RSpec::DSL
        super
      end
    end
  end
end

RSpec.configure do |config|
  config.include(
    Pundit::RSpec::PolicyExampleGroup,
    type: :policy,
    file_path: %r{spec/policies}
  )
end
