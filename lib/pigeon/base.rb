# frozen_string_literal: true

require 'klass_name_extractor'

# defines Pigeon::Base, the dad of all pigeons.
module Pigeon
  class Base
    include KlassNameExtractor

    class << self
      def skip(*flight_routes_types)
        define_method(:skipped_flight_routes) do
          @skipped_flight_routes = flight_routes_types
        end
      end

      def flight_routes
        @flight_routes ||= {}
      end

      def register_flight_route(route_name, flight_route)
        flight_routes[route_name] = flight_route
      end

      def template_formats(**map)
        @template_formats = map || {}
      end

      def fly_action(mid, **kwargs)
        new(**kwargs).tap do |pigeon|
          pigeon.run_callbacks(:flying) do
            pigeon.send(mid)
            pigeon.fly(mid)
          end
        end
      end

      def method_missing(mid, *args, &block)
        if instance_methods(false).include? mid
          fly_action(mid, *args)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        instance_methods(false).include?(method_name) || super
      end
    end

    def self.inherited(subclass)
      subclass.class_eval do
        object_type :pigeon

        include Pigeon::Callbacks

        Pigeon::FlightRouteRegisterer.call(subclass)
      end
    end

    attr_reader :flight_routes, :params, :mid

    # set the routes to fly
    def initialize(**kwargs)
      @template_formats = template_formats
      @skipped_flight_routes = []
      @flight_routes = self.class.flight_routes
      @pigeon_name = abstract_klass_string
      @recipient ||= kwargs.delete(:to)
      @async ||= kwargs.delete(:async) || Rails.env.development?
      @params = kwargs
    end

    # set message and call private do_fly method
    def fly(mid)
      @mid = mid

      if @async
        do_fly
      else
        Pigeon::FlyJob.fly_later(self.class.to_s, mid, **params)
      end
    end

    # flies without enqueing jobs
    def fly_now!(mid)
      @async = true

      fly(mid)
    end

    # determines which routes the pigeon should skip
    def skip(*flight_routes_types)
      @skipped_flight_routes.concat(flight_routes_types)
    end

    # determines whether the piegon is going to fly this route
    def flying_route?(route_type)
      skipped_flight_routes.exclude? route_type
    end

    # extracts context from the method in the pigeon, to be injected in each flight route
    def context
      instance_variables.map { |attribute| [attribute, instance_variable_get(attribute)] }.to_h
    end

    private

    attr_reader :skipped_flight_routes

    def do_fly
      flight_routes.each do |route_name, _route_object|
        # next unless route.fly?(args)
        next unless flying_route?(route_name)

        fly_route(route_name)
      end
      self
    end

    def fly_route(type)
      raise NoMessageError, 'There are no messages to deliver' unless mid

      begin
        flight_routes[type].fly(mid, context, **params)
      rescue
        _logger.error "Error in #{self.class}##{mid}: Could not send #{type.to_s.titleize}!."
      else
        _logger.debug "#{type.to_s.titleize} processed."
      end
    end

    def template_formats
      self.class.template_formats
    end

    def _logger
      @_logger ||= Logger.new(STDOUT)
    end
  end
end
