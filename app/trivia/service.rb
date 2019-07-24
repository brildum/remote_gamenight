# frozen_string_literal: true

# typed: true

require_relative './models'

module Trivia
  # Service defines the API for interacting with trivia games
  class Service
    def initialize
      @num_clues = Clue.count
    end

    def random_clue
      random_id = Random.new.rand(@num_clues) + 1
      Clue.find_by!(id: random_id)
    end
  end
end
