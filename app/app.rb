# Disable types because sinatra is not does not play nicely with Sorbet (yet)
# typed: false

require 'sinatra'

require './app/slack_controller'

# App defines the HTTP server
class App < Sinatra::Base
  include Sinatra::Helpers

  def self.init!(_environment, services)
    @@services = services
    @@slack = SlackController.new(services)
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

  post '/hooks/slack' do
    payload = JSON.parse(request.body.read)
    @@slack.hook(payload)
  end

  not_found do
    body 'Page Not Found'
  end
end
