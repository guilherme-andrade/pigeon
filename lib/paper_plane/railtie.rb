# frozen_string_literal: true

require 'railties/rails/railtie'

module PaperPlane
  class Railtie < ::Rails::Railtie
    config.eager_load_namespaces << PaperPlane

    # generators do
    #   require 'path/to/my_railtie_generator'
    # end
  end
end
