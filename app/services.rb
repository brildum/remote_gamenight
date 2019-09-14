# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

require './app/clients'
require './app/trivia/service'

# Services provides access to all services/clients
class Services
  extend T::Sig

  sig { returns(Clients) }
  attr_reader :clients

  sig { returns(Trivia::Service) }
  attr_reader :trivia

  sig { params(config: Config::Data).void }
  def initialize(config)
    @config = T.let(config, Config::Data)
    db_connect!
    @clients = T.let(Clients.new(@config), Clients)
    @logger = T.let(@clients.logger, Logger)
    @trivia = T.let(Trivia::Service.new(@clients), Trivia::Service)
  end

  sig { void }
  def connect!
    db_connect!
    @clients.connect!
  end

  sig { void }
  def disconnect!
    ActiveRecord::Base.connection.disconnect!
    @clients.disconnect!
  end

  sig { void }
  private def db_connect!
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      host: 'localhost',
      username: 'gamenight',
      password: Secrets::DB_PASSWORD,
      database: @config.get('dbname'),
    )
  end
end
