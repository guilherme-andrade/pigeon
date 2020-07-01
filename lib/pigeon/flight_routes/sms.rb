module Pigeon
  module FlightRoutes
    class Sms < Base
      default_to Deliverer::Base

      def do_fly
        @_route_klass.call(message_payload)
      end

      def message_payload
        {
          to: recipient.full_mobile_number,
          message: template,
          intercept: recipient.intercept_sms
        }
      end
    end
  end
end
