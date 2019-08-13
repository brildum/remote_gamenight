# frozen_string_literal: true

# typed: true

require 'resque'
require 'sorbet-runtime'
require 'sinatra'

require './app/config'
require './app/services'
require './app/http'

require './jobs/events/slack_hook'

require_relative './models'

module Slack
  # Controller provides Slack webhooks
  class Controller
    extend T::Sig

    sig { params(config: Config::Data, services: Services).void }
    def initialize(config, services)
      @config = config
      @services = services
    end

    sig { params(code: String).returns(T::Boolean) }
    def init(code)
      data = @services.clients.slack.authenticate(code)

      team = Slack::Team.find_by(slack_team_id: data['team_id'])
      team = Slack::Team.new(slack_team_id: data['team_id']) if team.nil?

      team.slack_team_name = data['team_name']
      team.slack_user_id = data['user_id']
      team.slack_user_token = data['access_token']
      team.slack_bot_id = data['bot']['bot_user_id']
      team.slack_bot_token = data['bot']['bot_access_token']
      team.save!
    end

    sig { params(payload: T::Hash[String, T.untyped]).returns(JSONResponse) }
    def hook(payload)
      case payload['type']
      when 'url_verification'
        return JSONResponse.new({
          challenge: payload['challenge']
        })
      when 'event_callback'
        event = payload['event']
        logger.info "Received Slack event_callback: #{event}"
        Resque.enqueue(Jobs::Events::SlackHook, event)
        # case event['type']
      end

      default_response
    end

    sig { params(event: T::Hash[String, T.untyped]).void }
    def on_app_mention(event)
      team = Slack::Team.find_by(slack_team_id: event['team'])
      return if team.nil?

      send_message = lambda do |msg|
        @services.clients.slack.send_message(team.slack_bot_token, event['channel'], "```#{msg}```")
      end

      msg = parse_message(team.slack_bot_id, event['text'])
      match = %r{^!([a-z0-9_-]+)\s*(.*)$}i.match(msg)
      if match.nil?
        send_message.call("You need to specify a command, ie: `#{@config.get('botname')} !command arg1 arg2...`")
        return
      end

      game_id = "#{team.slack_team_id}:#{event['channel']}"

      cmd = match.captures[0]
      args = (match.captures[1] || '').split
      case cmd
      when 'play'
        case args[0]
        when 'trivia'
          game = @services.trivia.get_game(game_id)
          if game && game.state != Trivia::Game::State::COMPLETED
            case game.state
            when Trivia::Game::State::STARTING
              send_message.call("A game has already been started. Pick your team!\n\nTry:\n\n#{@config.get('botname')} !register @user1 @user2 @user3 My Team Name")
            when Trivia::Game::State::STARTED
              send_message.call('A game is already in progress!')
            end
            return
          end

          game = Trivia::Game.new(
            id: game_id,
            state: Trivia::Game::State::STARTING,
            teams: [],
            scores: {},
            active_clue: nil,
            num_clues: 0
          )
          @services.trivia.start_game(game)
          send_message.call("A new game has started. Its time to pick teams!\n\nTry:\n\n#{@config.get('botname')} !register @user1 @user2 @user3 My Team Name")
        else
          send_message.call('Invalid !play argument. Valid options are [trivia]')
        end
      else
        send_message.call("Invalid command !#{cmd}")
      end
    end

    sig { params(event: T::Hash[String, T.untyped]).void }
    def on_message(event)
      team = Slack::Team.find_by(slack_team_id: event['team'])
      return if team.nil? || team.slack_bot_id == event['bot_id']

      send_message = lambda do |msg|
        @services.clients.slack.send_message(team.slack_bot_token, event['channel'], "```#{msg}```")
      end

      msg = parse_message(team.slack_bot_id, event['text'])
      send_message.call(msg)
    end

    sig { void }
    def sync_games
      logger.info 'syncing games'
      @services.trivia.active_games.each do |game|
        logger.info "game: #{game.id}"
      end
    end

    private

    sig { returns(Logger) }
    def logger
      @services.clients.logger
    end

    sig { params(bot_id: String, text: String).returns(String) }
    def parse_message(bot_id, text)
      mention = "<@#{bot_id}>"
      text.gsub(mention, '').strip
    end

    def default_response
      JSONResponse.new(nil)
    end
  end
end
