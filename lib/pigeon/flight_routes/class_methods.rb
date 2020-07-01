module Pigeon
  module FlightRoutes
    module ClassMethods
      def default_to(route_klass)
        @route_klass = route_klass
      end

      def default_views(folder_path)
        @default_views_folder = folder_path
      end

      def default_format(format)
        @default_template_format = format
      end

      def default_views_folder
        @default_views_folder
      end

      def default_route_klass
        @route_klass
      end

      def default_template_format
        @default_template_format
      end
    end
  end
end
