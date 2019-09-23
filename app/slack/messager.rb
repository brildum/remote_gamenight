# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

require './lib/slack_api'

module Slack
  # Message defines a message we can send to slack and allows richer formatting options
  class Message < T::Struct
    # Block defines a Slack message block
    class Block < T::Struct
      extend T::Sig

      prop :text, String

      sig { returns(T::Hash[T.untyped, T.untyped]) }
      def to_hash
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: text,
          },
        }
      end
    end

    # Attachment defines a Slack message attachment
    class Attachment < T::Struct
      extend T::Sig

      prop :color, T.nilable(String)
      prop :text, String

      sig { returns(T::Hash[T.untyped, T.untyped]) }
      def to_hash
        out = { text: text }
        out[:color] = color if color && !color.blank?
        out
      end
    end

    prop :blocks, T::Array[Block]
    prop :attachments, T::Array[Attachment]
  end

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

    sig do
      params(
        _key: Symbol,
        msg: T.any(String, Message),
      )
        .void
    end
    def send(_key, msg)
      if msg.is_a?(String)
        send_string(msg)
      else
        send_message(msg)
      end
    end

    sig { params(msg: Message).void }
    private def send_message(msg)
      @slack_api.send_message(
        bot_token: @team.slack_bot_token,
        channel: @channel,
        blocks: msg.blocks.map(&:to_hash),
        attachments: msg.attachments.map(&:to_hash),
      )
    end

    sig { params(msg: String).void }
    private def send_string(msg)
      blocks = [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: msg,
          },
        },
      ]
      @slack_api.send_message(
        bot_token: @team.slack_bot_token,
        channel: @channel,
        blocks: blocks,
        attachments: [],
      )
    end
  end
end
