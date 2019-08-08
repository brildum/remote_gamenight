require 'bundler'

Bundler.require

require './app/app'
require './app/services'

environment = ENV['RACK_ENV'] || 'production'

config = environment == 'production' ? Config::Prod : Config::Dev
services = Services.new(config)
App.init!(config, services)
run App
