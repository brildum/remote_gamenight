require 'bundler'

Bundler.require

require './app/app'
require './app/services'

environment = ENV['RACK_ENV'] || 'production'

services = Services.new(environment)
App.init!(environment, services)
run App
