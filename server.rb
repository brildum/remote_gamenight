#!/usr/bin/env ruby

# frozen_string_literal: true

# typed: strict

require './app/app'
require './app/services'

if $PROGRAM_NAME == __FILE__
  services = Services.new
  App.init!(services)
  App.run!
end
