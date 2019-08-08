# frozen_string_literal: true

# typed: true

require './app/clients'
require './app/trivia/service'

# Services provides access to all services/clients
class Services
  attr_reader :clients, :trivia

  def initialize(config)
    @config = config
    db_connect!
    @clients = Clients.new(@config)
    @logger = @clients.logger
    @redis = @clients.redis
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
      database: @config.get('dbname')
    )
  end
end
