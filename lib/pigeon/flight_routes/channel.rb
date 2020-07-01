module Pigeon
  module FlightRoutes
    class Channel < Base
      default_to ApplicationCable::Channel

      def fly(_mid, *args)
        # @route_klass.broadcast_to(*args)
      end
    end
  end
end
