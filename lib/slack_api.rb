# frozen_string_literal: true

# typed: true

require 'json'

require 'excon'
require 'sorbet-runtime'

require './lib/secrets'

# Slack is a Slack API client
class SlackAPI
  extend T::Sig

  class Error < StandardError; end

  def initialize(logger, redirect_uri)
    @logger = logger
    @redirect_uri = redirect_uri
    @conn = T.let(Excon.new('https://slack.com', persistent: false), Excon::Connection)
  end

  def connect!
    @conn = Excon.new('https://slack.com', persistent: false)
  end

  def disconnect!
    @conn.reset
  end

  sig { params(code: String).returns(T::Hash[String, T.untyped]) }
  def authenticate(code)
    payload = {
      client_id: Secrets::SLACK_CLIENT_ID,
      client_secret: Secrets::SLACK_CLIENT_SECRET,
      code: code,
      redirect_uri: @redirect_uri,
    }
    response = post_form('oauth.access', payload)
    JSON.parse(response.body)
  end

  sig { params(token: String, channel: String, msg: String).void }
  def send_message(token, channel, msg)
    payload = {
      token: token,
      channel: channel,
      text: msg,
    }
    response = post_json('chat.postMessage', payload, access_token: token)
    @logger.debug "chat.postMessage response: #{response.body}"
  end

  sig do
    params(
      endpoint: String,
      body: T::Hash[T.any(String, Symbol), T.untyped],
    )
      .returns(Excon::Response)
  end
  private def post_form(endpoint, body)
    response = @conn.post(
      path: "/api/#{endpoint}",
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded',
      },
      body: URI.encode_www_form(body),
    )

    raise Error, "invalid response #{response.status} for #{response.path}" if response.status != 200

    response
  end

  sig do
    params(
      endpoint: String,
      body: T.untyped,
      access_token: T.nilable(String),
    )
      .returns(Excon::Response)
  end
  private def post_json(endpoint, body, access_token: nil)
    headers = {
      'Content-Type' => 'application/json',
    }
    headers['Authorization'] = "Bearer #{access_token}" unless access_token.nil?

    response = @conn.post(
      path: "/api/#{endpoint}",
      headers: headers,
      body: body.to_json,
    )

    raise Error, "invalid response #{response.status} for #{response.path}" if response.status != 200

    response
  end
end
