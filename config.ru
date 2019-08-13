require 'bundler'

Bundler.require

require './app/app'
require './environment'

env = Environment.new
App.init!(env.config, env.services)
run App
