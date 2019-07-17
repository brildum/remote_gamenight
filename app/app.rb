# Disable types because sinatra is not does not play nicely with Sorbet (yet)
# typed: false

require 'sinatra/base'
require 'sinatra/reloader'

require './app/slack_controller'

# App defines the HTTP server
class App < Sinatra::Application
  extend Sinatra::Helpers

  def self.init!(services)
    @@slack = SlackController.new(services)
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
end
