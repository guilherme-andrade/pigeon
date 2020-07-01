# frozen_string_literal: true

require 'rails/railtie'

module Pigeon
  class Railtie < Rails::Railtie
    config.eager_load_namespaces << Pigeon
  end
end
