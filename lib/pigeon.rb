# frozen_string_literal: true

require 'pigeon/version'
require 'pigeon/base'
require 'pigeon/flight_route_registerer'
require 'pigeon/fly_job'
require 'pigeon/callbacks'

module Pigeon
  extend ActiveSupport::Autoload
end

require 'pigeon/railtie' if defined?(Rails)
