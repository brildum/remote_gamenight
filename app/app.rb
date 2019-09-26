# frozen_string_literal: true
# typed: false

require 'sinatra/base'
require 'sinatra/content_for'

require './app/config'
require './app/slack/controller'

# App defines the HTTP server
class App < Sinatra::Base
  include Sinatra::Helpers
  include Sinatra::ContentFor

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

  set :views, -> { File.join(settings.root, '..', 'templates') }

  configure :development do
    set :static, true
    set :public_folder, -> { File.join(settings.root, '..', 'static') }
  end

  get '/' do
    erb :home, layout: :layout
  end

  get '/slack/install' do
    params = URI.encode_www_form({
      client_id: Secrets::SLACK_CLIENT_ID,
      scope: 'bot',
      redirect_uri: "#{@@config.get('website')}/slack/init",
    })
    redirect "https://slack.com/oauth/authorize?#{params}", 302
  end

  get '/slack/init' do
    @@slack.init(request.params['code'])
    redirect '/slack/installed', 302
  end

  get '/slack/installed' do
    erb :slack_installed, layout: :layout
  end

  post '/slack/hook' do
    payload = JSON.parse(request.body.read)
    @@slack.hook(payload)
  end

  not_found do
    erb :not_found, layout: :layout
  end
end
