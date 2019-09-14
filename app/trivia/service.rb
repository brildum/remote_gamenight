# frozen_string_literal: true
# typed: strict

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
    prop :slack_team_id, String
    prop :slack_channel, String
    prop :teams, T::Array[String]
    prop :scores, T::Hash[String, Integer]
    prop :active_clue, T.nilable(Integer)
    prop :num_clues, Integer
    prop :started_at, Float
    prop :last_clue_sent_at, Float
    prop :answers_checked, T::Boolean

    sig { params(blob: String).returns(Game) }
    def self.from_json(blob)
      data = JSON.parse(blob)
      Game.new(
        id: data['id'],
        state: data['state'].to_sym,
        slack_team_id: data['slack_team_id'],
        slack_channel: data['slack_channel'],
        teams: data['teams'],
        scores: data['scores'],
        active_clue: data['active_clue'],
        num_clues: data['num_clues'],
        started_at: data['started_at'].to_f,
        last_clue_sent_at: data['last_clue_sent_at'].to_f,
        answers_checked: !!data['answers_checked'],
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
    extend T::Sig

    prop :game_id, String
    prop :team, String

    sig { params(blob: String).returns(TeamRegistration) }
    def self.from_json(blob)
      data = JSON.parse(blob)
      TeamRegistration.new(
        game_id: data['game_id'],
        team: data['team'],
      )
    end
  end

  # Service defines the API for interacting with trivia games
  class Service
    extend T::Sig

    sig { params(clients: Clients).void }
    def initialize(clients)
      @clients = T.let(clients, Clients)
      @num_clues = T.let(Clue.count, Integer)
    end

    sig { returns(T::Hash[String, Game]) }
    def active_games
      game_ids = @clients.redis.hgetall(all_active_games_key)
      return {} if game_ids.nil?

      game_ids.keys.each_with_object({}) { |gid, hash| hash[gid] = get_game(gid) }.keep_if { |_, v| !v.nil? }
    end

    sig { params(game_id: String).returns(T.nilable(Game)) }
    def get_game(game_id)
      result = @clients.redis.get(game_key(game_id))
      return nil if result.nil?

      Game.from_json(result)
    end

    sig { params(game_id: String).returns(T.nilable(Game)) }
    def get_active_game(game_id)
      game_id = @clients.redis.hget(all_active_games_key, game_id)
      return nil if game_id.nil?

      get_game(game_id)
    end

    sig { params(game: Game).void }
    def save_game(game)
      if game.state == Game::State::COMPLETED
        @clients.redis.hdel(all_active_games_key, game.id, game.id)
      else
        @clients.redis.hset(all_active_games_key, game.id, game.id)
      end
      result = @clients.redis.set(game_key(game.id), game.to_json)
      raise StandardError, 'failed to save game to redis' unless result == 'OK'
    end

    sig { params(game: Game).void }
    def delete_game(game)
      @clients.redis.hdel(all_active_games_key, game.id)
      @clients.redis.del(game_key(game.id))
    end

    sig do
      params(
        game: Game,
        team_name: String,
        users: T::Array[String],
      ).void
    end
    def register_team(game:, team_name:, users:)
      team_reg = TeamRegistration.new(
        game_id: game.id,
        team: team_name,
      )

      @clients.redis.hset(game_teams_key(game.id), team_name, users.to_json)

      users.each do |user|
        old_team_reg = get_team_for_user(user)
        if old_team_reg
          old_users_blob = @clients.redis.hget(game_teams_key(old_team_reg.game_id), old_team_reg.team)
          if old_users_blob
            begin
              filtered_users = T.cast(JSON.parse(old_users_blob), T::Array[String]).filter { |x| x != user }
            rescue JSON::ParserError
              filtered_users = []
            end
            if filtered_users.empty?
              @clients.redis.hdel(game_teams_key(old_team_reg.game_id), old_team_reg.team)
            end
          end
        end

        result = @clients.redis.set(user_registration_key(user), team_reg.to_json)
        raise StandardError, 'failed to write user team_registration in redis' unless result == 'OK'
      end
    end

    sig { params(user: String).returns(T.nilable(TeamRegistration)) }
    def get_team_for_user(user)
      result = @clients.redis.get(user_registration_key(user))
      return nil if result.nil?

      TeamRegistration.from_json(result)
    end

    sig { params(game: Game).returns(T::Hash[String, T::Array[String]]) }
    def get_teams_for_game(game)
      teams = @clients.redis.hgetall(game_teams_key(game.id))
      teams.keys.each_with_object({}) do |team, hash|
        hash[team] = T.cast(JSON.parse(teams[team]), T::Array[String])
      rescue JSON::ParserError => e
        logger.warn "failed to parse json teams: #{e}"
      end
    end

    sig do
      params(
        game: Game,
        team: String,
        answer: String,
      )
        .void
    end
    def add_answer(game:, team:, answer:)
      @clients.redis.hset(answers_key(game.id), team, answer)
    end

    sig { params(game: Game).returns(T::Hash[String, String]) }
    def get_answers(game)
      @clients.redis.hgetall(answers_key(game.id))
    end

    sig { params(game: Game).void }
    def clear_answers(game)
      @clients.redis.del(answers_key(game.id))
    end

    sig { params(clue_id: Integer).returns(Clue) }
    def get_clue(clue_id)
      Clue.find_by(id: clue_id)
    end

    sig { returns(Clue) }
    def random_clue
      get_clue(Random.new.rand(@num_clues) + 1)
    end

    sig { returns(String) }
    private def all_active_games_key
      'all_active_games'
    end

    sig { params(game_id: String).returns(String) }
    private def game_key(game_id)
      "game:#{game_id}"
    end

    sig { params(user_id: String).returns(String) }
    private def user_registration_key(user_id)
      "user_reg:#{user_id}"
    end

    sig { params(game_id: String).returns(String) }
    private def game_teams_key(game_id)
      "game_teams:#{game_id}"
    end

    sig { params(game_id: String).returns(String) }
    private def answers_key(game_id)
      "answers:#{game_id}"
    end

    sig { returns(Logger) }
    private def logger
      @clients.logger
    end
  end
end
