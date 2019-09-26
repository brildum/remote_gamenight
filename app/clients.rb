# frozen_string_literal: true
# typed: strict

require 'logger'

require 'active_record'
require 'redis'
require 'sorbet-runtime'

require './lib/secrets'
require './lib/slack_api'

# Clients defines service clients
class Clients
  extend T::Sig

  sig { params(config: Config::Data).void }
  def initialize(config)
    @logger = T.let(Logger.new(STDERR), Logger)
    @logger.level = :info
    @redis = T.let(Redis.new, Redis)
    @slack = T.let(SlackAPI.new(@logger, "#{config.get('website')}/slack/init"), SlackAPI)
  end

  sig { void }
  def connect!
    @slack.connect!
  end

  sig { void }
  def disconnect!
    @slack.disconnect!
  end

  sig { returns(Logger) }
  attr_reader :logger

  sig { returns(Redis) }
  attr_reader :redis

  sig { returns(SlackAPI) }
  attr_reader :slack
end
