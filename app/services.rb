# frozen_string_literal: true

# typed: true

require './app/clients'
require './app/trivia/service'
require './lib/slack'

# Services provides access to all services/clients
class Services
  attr_reader :logger, :redis, :slack, :trivia

  def initialize(environment)
    @environment = environment
    db_connect!
    @clients = Clients.new(environment)
    @logger = @clients.logger
    @redis = @clients.redis
    @slack = Slack.new
    @trivia = Trivia::Service.new(@clients)
  end

  def connect!
    db_connect!
    @clients.connect!
  end

  def disconnect!
    ActiveRecord::Base.connection.disconnect!
    @clients.disconnect!
  end

  private

  def db_connect!
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      host: 'localhost',
      username: 'gamenight',
      password: Secrets::DB_PASSWORD,
      database: @environment == 'production' ? 'gamenight_prod' : 'gamenight_dev'
    )
  end
end
