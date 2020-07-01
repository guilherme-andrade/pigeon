module Pigeon
  module FlightRoutes
    class Email < Base
      default_to ApplicationMailer

      private

      def do_fly
        _preprend_view_lookup
        _insert_mailer_method
        _set_layout

        @_template_formats = %i[html text]

        mail = @_route_klass.send(@method, context.merge(headers: headers))

        if Rails.env.development?
          LetterOpener::DeliveryMethod.new.deliver!(mail)
        else
          mail.deliver!
        end
      end

      def headers
        {
          template_path: _template_folder,
          template_name: _template_name,
          subject: subject,
          to: recipient.email,
          from: 'Christophe Vercarre <christophe@colochousing.com>',
          charset: 'utf-8',
          bcc: ENV['EMAIL_INTERCEPTOR_RECIPIENTS'].split(',')
        }
      end

      def subject
        @context.dig(:@subject)
      end

      def _insert_mailer_method
        @_route_klass.define_method(@method) do |context|
          context.each do |var, _v|
            next unless var.to_s.starts_with? '@'

            instance_variable_set(var, context.dig(var))
          end
          mail(context[:headers])
        end
      end

      def _preprend_view_lookup
        @_route_klass.prepend_view_path _default_views_folder
      end

      def _set_layout
        @_route_klass.layout 'email'
      end
    end
  end
end
