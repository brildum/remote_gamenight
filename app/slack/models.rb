# frozen_string_literal: true

# typed: strong

require 'active_record'

module Slack
  # Team defines an integration with a slack workspace
  class Team < ActiveRecord::Base
    self.table_name = 'slack_teams'
  end
end
