# frozen_string_literal: true

# typed: true

require 'logger'

require 'active_record'
require 'redis'

require './lib/secrets'
require './lib/slack_api'

# Clients defines service clients
class Clients
  attr_reader :logger, :redis, :slack

  def initialize(config)
    @logger = Logger.new(STDERR)
    @redis = Redis.new
    @slack = SlackAPI.new(@logger, "#{config.get('website')}/slack/init")
  end

  def connect!
    @slack.connect!
  end

  def disconnect!
    @slack.disconnect!
  end
end
