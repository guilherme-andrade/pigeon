require 'active_job'

module PaperPlane
  class FlyJob < ActiveJob::Base
    queue_as :paper_planes

    class << self
      alias_method :fly_later, :perform_later
    end

    def perform(paper_plane_name, action_name, **args)
      paper_plane_name.constantize.fly_action(action_name, **args.merge(async: true))
    end
  end
end
