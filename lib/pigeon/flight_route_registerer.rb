# frozen_string_literal: true

require 'pigeon/flight_routes/base'
require 'pigeon/flight_routes/email'
require 'pigeon/flight_routes/sms'
require 'pigeon/flight_routes/channel'

module Pigeon
  module FlightRouteRegisterer
    def self.call(klass)
      klass.class_eval do
        extend ClassMethods

        register_email
        register_channel
        register_sms
      end
    end

    module ClassMethods
      def register_email
        register_flight_route(:email, Pigeon::FlightRoutes::Email)
      end

      def register_channel
        register_flight_route(:channel, Pigeon::FlightRoutes::Channel)
      end

      def register_sms
        register_flight_route(:sms, Pigeon::FlightRoutes::Sms)
      end
    end
  end
end

# object_klass = begin
#                  object_klass_for(:deliverer)
#                rescue NameError
#                  nil
#                end
