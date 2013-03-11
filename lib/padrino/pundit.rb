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
        controller_name = request.route_obj.controller.to_s
        name = request.route_obj.named.to_s
        name.gsub!(/^#{controller_name}_?/, '')
        name = 'index' if name == ''
        name
      end
    end
  end
end
