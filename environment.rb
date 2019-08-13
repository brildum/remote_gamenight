# typed: true
# frozen_string_literal: true

require 'resque'

require './app/config'
require './app/services'

class Environment
  attr_reader :environment, :config, :services

  def initialize
    @environment = ENV['RACK_ENV'] == 'production' ? :production : :development
    @config = @environment == :production ? Config::Prod : Config::Dev
    @services = Services.new(@config)
    Resque.logger = @services.clients.logger
  end
end
