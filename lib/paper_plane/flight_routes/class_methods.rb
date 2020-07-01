module PaperPlane
  module FlightRoutes
    module ClassMethods
      def default_engine(engine)
        @engine = engine
      end

      def default_views(folder_path)
        @default_views_folder = folder_path
      end

      def default_format(format)
        @default_template_format = format
      end

      private

      def _default_views_folder
        @default_views_folder
      end

      def _engine
        @engine
      end

      def _default_template_format
        @default_template_format
      end
    end
  end
end
