require 'pigeon/flight_routes/class_methods'

module Pigeon
  module FlightRoutes
    NoRecipientError = Class.new(ArgumentError)
    NoTemplateError = Class.new(ArgumentError)
    DoFlyUndefined = Class.new(NoMethodError)

    class Base
      def self.inherited(subklass)
        subklass.class_eval do
          extend Pigeon::FlightRoutes::ClassMethods
          default_views 'app/pigeons'
        end
      end

      attr_accessor :context, :recipient

      def initialize(route_name = nil)
        @_route_name = route_name || _default_route_name
        @_route_klass = _default_route_klass
      end

      def self.fly(mid, context, **args)
        new.fly(mid, context, **args)
      end

      # to be overriden by children
      def fly(mid, context, **args)
        @method = mid
        @args = args
        @context = context

        _extract_recipient
        _extract_template_formats
        _extract_pigeon_name

        begin
          do_fly
        rescue NoTemplateError
          _logger.debug "'#{route_name}' skipped for lack of suited template => path: '#{_template_file_path}'; extension: #{_template_formats}."
        else
          _logger.debug "#{route_name} sent!"
        end
      end

      def do_fly
        raise DoFlyUndefined, 'Please override :do_fly in your flight route.'
      end

      private

      def contextualize
        context.each do |variable, value|
          next unless variable.to_s.starts_with? '@'

          instance_variable_set(variable, value)
        end
      end

      def action
        @method.to_s
      end

      def route_name
        @_route_name.to_s
      end

      def template
        return _renderer.render(*_render_payload) if _template_exists?

        raise NoTemplateError, "Could not find template for '#{_template_file_path}' with extension: #{_template_formats}"
      end

      def locale
        @locale || @recipient.locale || I18n.locale
      end

      def _render_payload
        [
          _view_context,
          template: _template_file_path,
          locals: _template_locals
        ]
      end

      def _logger
        @_logger ||= Logger.new(STDOUT)
      end

      def _template_locals
        context
      end

      def _lookup_context
        @_lookup_context ||= ActionView::LookupContext.new(_view_resolver)
      end

      def _view_resolver
        @_view_resolver ||= ActionView::FileSystemResolver.new(_default_views_folder)
      end

      def _view_context
        @_view_context ||= ActionView::Base.new(_lookup_context)
      end

      # def _output_buffer
      #   @_output_buffer ||= ActionView::OutputBuffer.new
      # end

      def _renderer
        @_renderer ||= ActionView::Renderer.new(_lookup_context)
      end

      def _template_formats
        @_template_formats = %i[text]
      end

      def _extract_template_formats
        @_template_formats = @context.dig(:@template_formats)
      end

      def _extract_pigeon_name
        @_pigeon_name = @context.dig(:@pigeon_name)
      end

      def _extract_recipient
        unless @context.key?(:@recipient)
          raise NoRecipientError, 'please specify the recipient value by setting @to = recipient'
        end

        @recipient = @context.dig(:@recipient)
      end

      def _template_file_path
        [_template_folder, _template_name].join('/')
      end

      def _template_name
        if _localized_template_exists?
          _localized_template_name
        else
          _base_template_name
        end
      end

      def _localized_file_path
        File.join(_full_template_folder_path, _localized_template_name)
      end

      def _localized_template_name
        [_base_template_name, '.', locale].join
      end

      def _base_template_name
        [action, route_name].join('/')
      end

      def _full_template_folder_path
        Rails.root.join(_default_views_folder, _template_folder)
      end

      def _template_folder
        _pigeon_templates_path
      end

      def _template_full_file_path
        File.join(_full_template_folder_path, _template_name)
      end

      def _default_route_klass
        self.class.default_route_klass
      end

      def _default_template_format
        self.class.default_template_format
      end

      def _default_views_folder
        Rails.root.join(self.class.default_views_folder)
      end

      def _pigeon_templates_path
        @_pigeon_name.underscore
      end

      def _default_route_name
        self.class.to_s.underscore.split('/').last
      end

      def _template_exists?
        !Dir.glob([_template_full_file_path, '*.*'].join).empty?
      end

      def _localized_template_exists?
        !Dir.glob([_localized_file_path, '*.*'].join).empty?
      end
    end
  end
end
