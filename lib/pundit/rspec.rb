module Pundit
  module RSpec
    module Matchers
      extend ::RSpec::Matchers::DSL

      matcher :permit do |user, record|
        match do |policy|
          permissions.all? { |permission| policy.new(user, record).public_send(permission) }
        end

        failure_message_for_should do |policy|
          "Expected #{policy} to grant #{permissions.to_sentence} on #{record} but it didn't"
        end

        failure_message_for_should_not do |policy|
          "Expected #{policy} not to grant #{permissions.to_sentence} on #{record} but it did"
        end

        def permissions
          example.metadata[:permissions]
        end
      end
    end

    module DSL
      def permissions(*list, &block)
        describe(list.to_sentence, :permissions => list, :caller => caller) { instance_eval(&block) }
      end
    end

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
  config.include Pundit::RSpec::PolicyExampleGroup, :type => :policy, :example_group => {
    :file_path => /spec\/policies/
  }
end
