# frozen_string_literal: true
# typed: false

module Jobs
  module Events
    module EventHandler
      def init!(config, services)
        @config = config
        @services = services
        init_handler
      end

      def perform(event)
        @services.disconnect!
        @services.connect!
        handle_event(event)
      end
    end
  end
end
