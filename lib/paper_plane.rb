# frozen_string_literal: true

require 'paper_plane/base'
require 'paper_plane/flight_route_registerer'
require 'paper_plane/fly_job'
require 'paper_plane/callbacks'

module PaperPlane
  extend ActiveSupport::Autoload
end

require 'paper_plane/railtie' if defined?(Rails)
