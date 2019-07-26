# frozen_string_literal: true

# typed: true

require 'logger'

require 'active_record'
require 'redis'

require './lib/secrets'

# Clients defines service clients
class Clients
  attr_reader :logger, :redis

  def initialize(_environment)
    @logger = Logger.new(STDERR)
    @redis = Redis.new
  end

  def connect!; end

  def disconnect!; end
end
