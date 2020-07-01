require 'active_job/base'

module Pigeon
  class FlyJob < ApplicationJob
    queue_as :pigeons

    class << self
      alias_method :fly_later, :perform_later
    end

    # queue_as do
    #   message = self.arguments.first
    #   if video.owner.premium?
    #     :premium_videojobs
    #   else
    #     :videojobs
    #   end
    # end

    def perform(pigeon_name, action_name, **args)
      pigeon_name.constantize.fly_action(action_name, **args.merge(async: true))
    end
  end
end
