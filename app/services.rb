# frozen_literal_string: true

# typed: true

require 'logger'

require './lib/slack'

# Services provides access to all services/clients
class Services
  attr_reader :logger, :slack, :trivia

  def initialize
    @logger = Logger.new(STDOUT)
    @slack = Slack.new
    @trivia_games = TriviaGames.new
  end
end
