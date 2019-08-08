# frozen_string_literal: true

# typed: true

require 'pry'

require 'sorbet-runtime'
require 'sinatra'

require './app/config'
require './app/services'
require './app/http'

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
        @services.clients.logger.info "Received Slack event_callback: #{event}"

        case event['type']
        when 'message'
          on_message(event)
        when 'app_mention'
          on_app_mention(event)
        end
      end

      default_response
    end

    sig { params(event: T::Hash[String, T.untyped]).returns(JSONResponse) }
    def on_app_mention(event)
      team = Slack::Team.find_by(slack_team_id: event['team'])
      return default_response if team.nil?

      send_message = lambda do |msg|
        @services.clients.slack.send_message(team.slack_bot_token, event['channel'], msg)
      end

      msg = parse_message(team.slack_bot_id, event['text'])
      match = %r{^\/([a-z0-9_-]+)\s*(.*)$}i.match(msg)
      if match.nil?
        send_message.call("You need to specify a command, ie: `#{@config.get('botname')} /command arg1 arg2...`")
        return default_response
      end

      game_id = "#{team.slack_team_id}:#{event['channel']}"

      case cmd = match.captures[0]
      when 'trivia'
        clue = @services.trivia.next_clue(game_id)
        send_message.call("```#{clue.clue}\n\nCategory: #{clue.category.name}```")
      when 'answer'
        clue = @services.trivia.active_clue(game_id)
        answer = (match.captures[1] || '').strip
        if @services.trivia.check_answer(clue, answer)
          send_message.call("```Correct!\n\n#{clue.answer}```")
        else
          send_message.call("```Incorrect!\n\n#{clue.answer}```")
        end
      else
        send_message.call("Invalid command /#{cmd}")
      end

      default_response
    end

    sig { params(event: T::Hash[String, T.untyped]).returns(JSONResponse) }
    def on_message(event)
      team = Slack::Team.find_by(slack_team_id: event['team'])
      return default_response if team.nil? || team.slack_bot_id == event['bot_id']

      send_message = lambda do |msg|
        @services.clients.slack.send_message(team.slack_bot_token, event['channel'], msg)
      end

      msg = parse_message(team.slack_bot_id, event['text'])
      send_message.call(msg)
      default_response
    end

    private

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
