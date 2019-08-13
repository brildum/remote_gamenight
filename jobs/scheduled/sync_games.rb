# frozen_string_literal: true

# typed: strong

require 'sorbet-runtime'

require './app/slack/controller'

module Jobs
  module Scheduled
    class SyncGames
      extend T::Sig

      sig { params(config: Config::Data, services: Services).void }
      def initialize(config, services)
        @controller = T.let(Slack::Controller.new(config, services), Slack::Controller)
      end

      sig { void }
      def run
        @controller.sync_games
      end
    end
  end
end
