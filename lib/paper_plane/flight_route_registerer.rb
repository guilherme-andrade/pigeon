# frozen_string_literal: true

require 'paper_plane/flight_routes/base'
require 'paper_plane/flight_routes/email'
require 'paper_plane/flight_routes/sms'

module PaperPlane
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
      end

      def register_channel
      end

      def register_sms
      end
    end
  end
end

# object_klass = begin
#                  object_klass_for(:deliverer)
#                rescue NameError
#                  nil
#                end
