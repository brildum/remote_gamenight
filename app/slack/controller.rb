# frozen_string_literal: true
# typed: strict

require 'resque'
require 'sorbet-runtime'
require 'sinatra'

require './app/config'
require './app/services'
require './app/http'

require './app/trivia/game_controller'

require './jobs/events/slack_hook'

require_relative './models'
require_relative './messager'
require_relative './command'

module Slack
  # Controller provides Slack webhooks
  class Controller
    extend T::Sig

    sig { params(config: Config::Data, services: Services).void }
    def initialize(config, services)
      @config = T.let(config, Config::Data)
      @services = T.let(services, Services)
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
          challenge: payload['challenge'],
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

      messager = Messager.new(
        team: team,
        channel: event['channel'],
        slack_api: @services.clients.slack,
      )

      begin
        command = Command.parse(parse_message(team.slack_bot_id, event['text']))
      rescue Slack::InvalidCommandError
        msg = "You need to specify a command, ie: #{@config.get('botname')} !command arg1 arg2..."
        messager.send(:invalid_cmd, msg)
        return
      end

      game_id = "#{team.slack_team_id}:#{event['channel']}"
      game = @services.trivia.get_active_game(game_id)

      case command.cmd
      when 'play'
        on_cmd_play(
          args: command.args,
          team: team,
          slack_channel: event['channel'],
          game_id: game_id,
          game: game,
          messager: messager,
        )
      when 'team'
        on_cmd_team(
          args: command.args,
          game: game,
          messager: messager,
        )
      when 'teams'
        on_cmd_teams(
          args: command.args,
          game: game,
          messager: messager,
        )
      else
        if game
          Trivia::GameController.new(
            config: @config,
            services: @services,
            game: game,
            messager: messager,
          ).on_command(command.cmd, command.args)
        else
          messager.send(:invalid_cmd, 'Unrecognized command')
        end
      end
    end

    sig { params(event: T::Hash[String, T.untyped]).void }
    def on_message(event)
      slack_team = Slack::Team.find_by(slack_team_id: event['team'])
      return if slack_team.nil? || slack_team.slack_bot_id == event['bot_id']

      messager = Messager.new(
        team: slack_team,
        channel: event['channel'],
        slack_api: @services.clients.slack,
      )

      # direct messages just have the ID but we receive <@{user_id}> in @mentions
      user = "<@#{event['user']}>"
      team_reg = @services.trivia.get_team_for_user(user)
      if team_reg.nil?
        messager.send(:message_unknown_team, 'You are not currently registered with any game.')
        return
      end

      game = @services.trivia.get_game(team_reg.game_id)
      if game.nil?
        messager.send(:message_unknown_team, 'You are not currently registered with any game.')
        return
      end

      begin
        command = Command.parse(parse_message(slack_team.slack_bot_id, event['text']))
      rescue InvalidCommandError
        msg = <<~DOC
          You need to submit your answers with:

          !answer Mark Twain
        DOC
        messager.send(:invalid_message_cmd, msg)
        return
      end

      case command.cmd
      when 'answer'
        Trivia::GameController.new(
          config: @config,
          services: @services,
          game: game,
          messager: messager,
        ).receive_answer(
          team: team_reg.team,
          answer: command.args.join(' '),
        )
      else
        msg = <<~DOC
          You need to submit your answers with:

          !answer Mark Twain
        DOC
        messager.send(:invalid_message_cmd, msg)
      end
    end

    sig { void }
    def sync_games
      logger.info 'syncing games'
      @services.trivia.active_games.each do |_game_id, game|
        team = Slack::Team.find_by(slack_team_id: game.slack_team_id)
        next if team.nil?

        messager = Slack::Messager.new(
          channel: game.slack_channel,
          team: team,
          slack_api: @services.clients.slack,
        )

        Trivia::GameController.new(
          config: @config,
          services: @services,
          game: game,
          messager: messager,
        ).sync_game
      end
    end

    sig do
      params(
        args: T::Array[String],
        game: T.nilable(Trivia::Game),
        messager: Slack::Messager,
      ).void
    end
    def on_cmd_team(args:, game:, messager:)
      if game.nil?
        msg = <<~DOC
          You cannot create a team before a game has started. Try:

          #{@config.get('botname')} !play <game>
        DOC
        messager.send(:team_cmd_no_game, msg)
        return
      end

      user_tokens = args.each_with_object({}) { |token, h| h[token] = token =~ /^<@\w+>$/ }
      users = args.filter { |token| user_tokens[token] }
      team_tokens = args.filter { |token| !user_tokens[token] }
      team = team_tokens.join(' ').strip

      if users.empty?
        msg = <<~DOC
          You must specify some users when creating a team.

          #{@config.get('botname')} !team @user1 @user2 My Team Name
        DOC
        messager.send(:team_cmd_no_users, msg)
        return
      end

      team = SecureRandom.hex(6) if team.empty?
      @services.trivia.register_team(
        game: game,
        team_name: team,
        users: users,
      )
      msg = "The team \"#{team}\" has been created. Good luck!\n\n#{users.join("\n")}"
      messager.send(:team_success, msg)
    end

    sig do
      params(
        args: T::Array[String],
        game: T.nilable(Trivia::Game),
        messager: Slack::Messager,
      ).void
    end
    def on_cmd_teams(args:, game:, messager:)
      if game.nil?
        msg = <<~DOC
          You cannot view teams before a game has started. Try:

          #{@config.get('botname')} !play <game>
        DOC
        messager.send(:teams_cmd_invalid, msg)
        return
      end

      teams_output = []
      @services.trivia.get_teams_for_game(game).each do |team, users|
        teams_output << "- #{team}: #{users.join(', ')}"
      end
      msg = <<~DOC
        Teams:

        #{teams_output.join("\n")}
      DOC
      messager.send(:teams_cmd_success, msg)
    end

    sig do
      params(
        args: T::Array[String],
        team: Slack::Team,
        slack_channel: String,
        game_id: String,
        game: T.nilable(Trivia::Game),
        messager: Slack::Messager,
      ).void
    end
    def on_cmd_play(args:, team:, slack_channel:, game_id:, game:, messager:)
      if game && args[1] != 'force'
        msg = <<~DOC
          A game is already in progress! To start a new game, use:

          #{@config.get('botname')} !play <game> force
        DOC
        messager.send(:game_already_started, msg)
        return
      end

      case args[0]
      when 'trivia'
        game = Trivia::Game.new(
          id: game_id,
          state: Trivia::Game::State::STARTING,
          slack_team_id: team.slack_team_id,
          slack_channel: slack_channel,
          teams: [],
          scores: {},
          active_clue: nil,
          num_clues: 0,
          started_at: Time.now.to_f,
          last_clue_sent_at: Time.now.to_f,
          answers_checked: false,
        )
        Trivia::GameController.new(
          config: @config,
          services: @services,
          game: game,
          messager: messager,
        ).activate_game
      else
        messager.send(:invalid_game_requested, 'Invalid game specified! Valid options are [trivia]')
      end
    end

    sig { returns(Logger) }
    private def logger
      @services.clients.logger
    end

    sig { params(bot_id: String, text: String).returns(String) }
    private def parse_message(bot_id, text)
      mention = "<@#{bot_id}>"
      text.gsub(mention, '').strip
    end

    sig { returns(JSONResponse) }
    private def default_response
      JSONResponse.new(nil)
    end
  end
end
