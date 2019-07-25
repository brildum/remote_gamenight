# frozen_string_literal: true

# typed: true

require 'logger'

require 'active_record'
require 'redis'

require './lib/secrets'

# Clients defines service clients
class Clients
  attr_reader :logger, :redis

  def initialize
    # initialize ActiveRecord first, since other services may depend on it
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      host: 'localhost',
      username: 'gamenight',
      password: Secrets::DB_PASSWORD,
      database: 'gamenight_dev'
    )

    @logger = Logger.new(STDERR)
    @redis = Redis.new
  end
end
