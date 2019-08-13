# typed: strict
# frozen_string_literal: true

require 'rufus-scheduler'

require './environment'
require './jobs/scheduled/sync_games'

env = Environment.new

# Jobs
sync_games = Jobs::Scheduled::SyncGames.new(env.config, env.services)

# Schedule
scheduler = Rufus::Scheduler.new
scheduler.every('5') { sync_games.run }

if $PROGRAM_NAME == __FILE__
  # This blocks forever
  scheduler.join
end
