# typed: true
# frozen_string_literal: true

require './jobs/events/slack_hook'

class Workers
  def self.init!(config, services)
    Jobs::Events::SlackHook.init!(config, services)
  end
end
