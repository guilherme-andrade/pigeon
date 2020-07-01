# frozen_string_literal: true

require 'active_support/version'
require 'active_support/callbacks'
require 'active_support/concern'

module Pigeon
  # Add callbacks support to Active Delivery (requires ActiveSupport::Callbacks)
  #
  #   # Run method before delivering notification
  #   # NOTE: when `false` is returned the executation is halted
  #   before_fly :do_something
  #
  #   # You can specify a notification method (to run callback only for that method)
  #   before_fly :do_mail_something, on: :mail
  #
  #   # or for push notifications
  #   before_fly :do_mail_something, on: :push
  #
  #   # after_ and around_ callbacks are also supported
  #   after_fly :cleanup
  #
  #   around_fly :set_context
  CALLBACK_TERMINATOR = if ::ActiveSupport::VERSION::MAJOR >= 5
                          ->(_target, result) { result.call == false }
                        else
                          ->(_target, result) { result == false }
                        end

  module Callbacks
    extend ActiveSupport::Concern

    include ActiveSupport::Callbacks

    included do
      define_flight_callbacks :flying
    end

    class_methods do
      def _normalize_callback_options(options)
        _normalize_callback_option(options, :only, :if)
        _normalize_callback_option(options, :except, :unless)
      end

      def _normalize_callback_option(options, from, to)
        if (from = options[from])
          from_set = Array(from).map(&:to_s).to_set
          from = proc { |c| from_set.include? c.notification_name.to_s }
          options[to] = Array(options[to]).unshift(from)
        end
      end

      def define_flight_callbacks(route_name)
        define_callbacks route_name,
          terminator: CALLBACK_TERMINATOR,
          skip_after_callbacks_if_terminated: true
      end

      def before_flying(method_or_block = nil, on: :flying, **options, &block)
        method_or_block ||= block
        _normalize_callback_options(options)
        set_callback on, :before, method_or_block, options
      end

      def after_flying(method_or_block = nil, on: :flying, **options, &block)
        method_or_block ||= block
        _normalize_callback_options(options)
        set_callback on, :after, method_or_block, options
      end

      def around_flying(method_or_block = nil, on: :flying, **options, &block)
        method_or_block ||= block
        _normalize_callback_options(options)
        set_callback on, :around, method_or_block, options
      end
    end
  end
end
