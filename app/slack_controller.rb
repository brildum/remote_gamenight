# frozen_string_literal: true

# typed: true

require 'sorbet-runtime'
require 'sinatra'

require './app/services'
require './app/http'

BOT_ID = 'BL3Q8JD98'
BOT_USER_ID = 'UL3Q8JDEW'
BOT_MENTION = "<@#{BOT_USER_ID}>"

# SlackController provides Slack webhooks
class SlackController
  extend T::Sig

  sig { params(services: Services).void }
  def initialize(services)
    @services = services
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
      @services.logger.info "Received Slack event_callback: #{event}"

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
    return default_response if event['bot_id'] == BOT_ID

    send_message = lambda do |msg|
      @services.slack.send_message(event['channel'], msg)
    end

    msg = parse_message(event['text'])
    match = %r{^\/([a-z0-9_-]+)\s*(.*)$}i.match(msg)
    if match.nil?
      send_message.call('You need to specify a command, ie: "@remote_gamenight /command arg1 arg2..."')
      return default_response
    end

    case cmd = match.captures[0]
    when 'trivia'
      clue = @services.trivia.random_clue
      send_message.call("```#{clue.clue}\n\nCategory: #{clue.category.name}```")
    else
      send_message.call("Invalid command /#{cmd}")
    end

    default_response
  end

  sig { params(event: T::Hash[String, T.untyped]).returns(JSONResponse) }
  def on_message(event)
    return default_response if event['bot_id'] == BOT_ID

    send_message = lambda do |msg|
      @services.slack.send_message(event['channel'], msg)
    end

    msg = parse_message(event['text'])
    send_message.call(msg)
    default_response
  end

  private

  sig { params(text: String).returns(String) }
  def parse_message(text)
    text.gsub(BOT_MENTION, '').strip
  end

  def default_response
    JSONResponse.new(nil)
  end
end
