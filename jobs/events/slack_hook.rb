# typed: true
# frozen_string_literal: true

require 'json'
require 'resque'
require 'sorbet-runtime'

require './app/slack/controller'

require_relative './base'

module Jobs
  module Events
    # SlackHook processes slack hook events asynchronously
    class SlackHook
      extend T::Sig
      extend EventHandler

      @queue = :slack_hook

      sig { void }
      def self.init_handler
        @controller = Slack::Controller.new(@config, @services)
      end

      sig { params(event: T::Hash[String, T.untyped]).void }
      def self.handle_event(event)
        @services.clients.logger.debug "handling slack_hook event: #{event}"
        case event['type']
        when 'message'
          @controller.on_message(event)
        when 'app_mention'
          @controller.on_app_mention(event)
        end
      end
    end
  end
end
