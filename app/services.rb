# frozen_string_literal: true

# typed: true

require './app/clients'
require './app/trivia/service'
require './lib/slack'

# Services provides access to all services/clients
class Services
  attr_reader :logger, :redis, :slack, :trivia

  def initialize
    @clients = Clients.new
    @logger = @clients.logger
    @redis = @clients.redis
    @slack = Slack.new
    @trivia = Trivia::Service.new(@clients)
  end
end
