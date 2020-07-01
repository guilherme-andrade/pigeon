require 'action_mailer'

module PaperPlane
  module FlightRoutes
    class Email < Base
      default_engine ActionMailer::Base

      private

      def do_fly
        _preprend_view_lookup
        _insert_mailer_method
        _set_layout

        @_template_formats = %i[html text]

        mail = @_engine.send(@method, context.merge(headers: headers))

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
        @_engine.define_method(@method) do |context|
          context.each do |var, _v|
            next unless var.to_s.starts_with? '@'

            instance_variable_set(var, context.dig(var))
          end
          mail(context[:headers])
        end
      end

      def _preprend_view_lookup
        @_engine.prepend_view_path _default_views_folder
      end

      def _set_layout
        @_engine.layout 'email'
      end
    end
  end
end
