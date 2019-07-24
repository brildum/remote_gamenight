# frozen_string_literal: true

# typed: true

require 'logger'

require 'active_record'

require './app/trivia/service'
require './lib/slack'

# Services provides access to all services/clients
class Services
  attr_reader :logger, :slack, :trivia

  def initialize
    # initialize ActiveRecord first, since other services may depend on it
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'dev_db.sqlite'
    )

    @logger = Logger.new(STDERR)
    @slack = Slack.new
    @trivia = Trivia::Service.new
  end
end
