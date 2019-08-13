# frozen_string_literal: true

# typed: true

require 'amatch'
require 'json'
require 'sorbet-runtime'

require './app/clients'

require_relative './models'
require_relative './nlp'

module Trivia
  # Game defines data that represents game state
  class Game < T::Struct
    extend T::Sig

    prop :id, String
    prop :state, Symbol
    prop :teams, T::Array[String]
    prop :scores, T::Hash[String, Integer]
    prop :active_clue, T.nilable(Integer)
    prop :num_clues, Integer

    sig { params(blob: String).returns(Game) }
    def self.from_json(blob)
      data = JSON.parse(blob)
      Game.new(
        id: data['id'],
        state: data['state'].to_sym,
        teams: data['teams'],
        scores: data['scores'],
        active_clue: data['active_clue'],
        num_clues: data['num_clues']
      )
    end

    module State
      STARTING = :starting
      STARTED = :started
      COMPLETED = :completed
    end
  end

  # TeamRegistration identifies which game/team a user is participating with
  class TeamRegistration < T::Struct
    prop :game_id, String
    prop :team, String
  end

# Service defines the API for interacting with trivia games
  class Service
    extend T::Sig

    sig { params(clients: Clients).void }
    def initialize(clients)
      @clients = T.let(clients, Clients)
      @num_clues = T.let(Clue.count, Integer)
    end

    sig { returns(T::Array[Game]) }
    def active_games
      game_ids = @clients.redis.hgetall(all_active_games_key)
      return [] if game_ids.nil?

      game_ids.keys.map { |gid| get_game(gid) }.compact
    end

    sig { params(game_id: String).returns(T.nilable(Game)) }
    def get_game(game_id)
      result = @clients.redis.get(game_key(game_id))
      return nil if result.nil?

      Game.from_json(result)
    end

    sig { params(game: Game).void }
    def save_game(game)
      result = @clients.redis.set(game_key(game.id), game.to_json)
      raise StandardError, 'failed to save game to redis' unless result == 'OK'
    end

    sig { params(game: Game).void }
    def start_game(game)
      @clients.redis.hset(all_active_games_key, game.id, game.id)
      save_game(game)
    end

    sig do
      params(
        game: Game,
        team_name: String,
        users: T::Array[String]
      ).void
    end
    def register_team(game, team_name, users)
      team_reg = TeamRegistration.new(
        game_id: game.id,
        team: team_name
      )

      users.each do |user|
        result = @clients.redis.set(user_registration_key(user), team_reg.to_json)
        raise StandardError, 'failed to write data user team key in redis' unless result == 'OK'
      end
    end

    sig { params(clue: Clue, possible_answer: String).returns(T::Boolean) }
    def check_answer(clue, possible_answer)
      real_tokens = tokenize(clue.answer)
      possible_tokens = tokenize(possible_answer)

      real = real_tokens.join(' ')
      possible = possible_tokens.join(' ')

      value = real.jarowinkler_similar(possible)
      @clients.logger.debug "#{real} vs #{possible} [jarowinkler:#{value}]"
      return true if value >= 0.9

      # "steelers" vs "pittsburgh steelers"
      if real_tokens.length <= 2 && possible_tokens.length <= 2
        return real_tokens[-1].levenshtein_similar(possible_tokens[-1]) >= 0.8
      end

      false
    end

    private

    def tokenize(text)
      text.downcase.gsub(/[^a-z0-9\s]+/, '').split.filter { |x| !STOPWORDS.key?(x) }
    end

    sig { returns(String) }
    def all_active_games_key
      'all_active_games'
    end

    sig { params(game_id: String).returns(String) }
    def game_key(game_id)
      "game:#{game_id}"
    end

    sig { params(user_id: String).returns(String) }
    def user_registration_key(user_id)
      "user_reg:#{user_id}"
    end

    sig { returns(Logger) }
    def logger
      @clients.logger
    end
  end
end
