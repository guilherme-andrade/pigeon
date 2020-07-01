require 'twilio-ruby'

module PaperPlane
  module FlightRoutes
    class Sms < Base
      default_engine Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

      def do_fly
        return if intercept?

        @_engine.create(message_payload)
      end

      def message_payload
        {
          from: ENV['TWILIO_NUMBER'],
          to: recipient.full_mobile_number,
          body: template
        }
      end

      def intercept?; end
    end
  end
end
