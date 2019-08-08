# Disable types because sinatra is not does not play nicely with Sorbet (yet)
# typed: false

require 'sinatra'

require './app/config'
require './app/slack/controller'

# App defines the HTTP server
class App < Sinatra::Base
  include Sinatra::Helpers

  def self.init!(config, services)
    @@config = config
    @@services = services
    @@slack = Slack::Controller.new(config, services)
  end

  def self.connect!
    @@services.connect!
  end

  def self.disconnect!
    @@services.disconnect!
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    body 'OK!'
  end

  get '/slack/install' do
    params = URI.encode_www_form({
      client_id: Secrets::SLACK_CLIENT_ID,
      scope: 'bot',
      redirect_uri: "#{@@config.get('website')}/slack/init"
    })
    redirect "https://slack.com/oauth/authorize?#{params}", 302
  end

  get '/slack/init' do
    @@slack.init(request.params['code'])
  end

  post '/slack/hook' do
    payload = JSON.parse(request.body.read)
    @@slack.hook(payload)
  end

  not_found do
    body 'Page Not Found'
  end
end
