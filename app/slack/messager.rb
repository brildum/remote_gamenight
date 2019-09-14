# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

require './lib/slack_api'

module Slack
  # Messager sends messages to a particular team/channel
  class Messager
    extend T::Sig

    sig do
      params(
        team: Team,
        channel: String,
        slack_api: SlackAPI,
      )
        .void
    end
    def initialize(team:, channel:, slack_api:)
      @team = T.let(team, Team)
      @channel = T.let(channel, String)
      @slack_api = T.let(slack_api, SlackAPI)
    end

    sig { params(_key: Symbol, msg: String).void }
    def send(_key, msg)
      @slack_api.send_message(@team.slack_bot_token, @channel, "```#{msg}```")
    end
  end
end
