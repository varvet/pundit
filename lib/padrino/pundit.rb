module Padrino
  module Pundit
    class << self
      def registered(app)
        app.helpers Padrino::Pundit::Adapter
        app.helpers ::Pundit
      end
    end

    module Adapter
      def action_name
        request.action.to_s
      end
    end
  end
end
