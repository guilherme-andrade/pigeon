# frozen_string_literal: true

class PaperPlaneGenerator < Rails::Generators::NamedBase
  argument :messages, type: :array, default: [], banner: 'action action'

  TEMPLATE_ROUTES = {
    email: 'md',
    sms: 'text'
  }.freeze

  def create_paper_plane_file
    template('paper_plane.rb', File.join('app/paper_planes', class_path, "#{file_name}_paper_plane.rb"))

    messages.each do |message|
      I18n.available_locales.each do |locale|
        flight_routes.each do |route_name, route_extension|
          template(
            "#{route_name}",
            File.join(
              'app/paper_planes',
              class_path,
              file_name,
              message,
              "#{route_name}.#{locale}.#{route_extension}.erb"
            )
          )
        end
      end
    end
  end

  def flight_routes
    TEMPLATE_ROUTES.except(*options[:skip_routes])
  end
end


