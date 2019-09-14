# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Slack
  class InvalidCommandError < StandardError; end

  # Command defines a Slack command `!command some args here`
  class Command < T::Struct
    extend T::Sig

    prop :cmd, String
    prop :args, T::Array[String]

    sig { params(msg: String).returns(Command) }
    def self.parse(msg)
      match = /^!([a-z0-9_-]+)\s*(.*)$/i.match(msg)
      raise InvalidCommandError if match.nil?

      Command.new(cmd: T.must(match.captures[0]), args: match.captures[1].to_s.split)
    end
  end
end
