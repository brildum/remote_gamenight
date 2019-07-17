# frozen_string_literal: true

# typed: true

require 'json'

require 'faraday'
require 'sorbet-runtime'

require './lib/secrets'

# Slack is a Slack API client
class Slack
  extend T::Sig

  class Error < StandardError; end

  def initialize
    @access_token = T.let(Secrets::SLACK_OAUTH_TOKEN, String)
    @conn = T.let(Faraday.new('https://slack.com/api/'), Faraday::Connection)
  end

  sig { params(channel: String, msg: String).void }
  def send_message(channel, msg)
    payload = {
      channel: channel,
      text: msg
    }
    post_json('chat.postMessage', payload)
  end

  private

  sig { params(endpoint: String, body: T.untyped).returns(Faraday::Response) }
  def post_json(endpoint, body)
    response = @conn.post(endpoint) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{@access_token}"
      req.body = body.to_json
    end

    raise Error, "invalid response #{response.status} for URL #{response.url}" if response.status != 200

    response
  end
end
