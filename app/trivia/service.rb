# frozen_string_literal: true

# typed: false

require 'amatch'

require './app/clients'

require_relative './models'
require_relative './nlp'

module Trivia
  # Service defines the API for interacting with trivia games
  class Service
    extend T::Sig

    sig { params(clients: Clients).void }
    def initialize(clients)
      @clients = clients
      @num_clues = Clue.count
    end

    sig { params(game_id: String).returns(Clue) }
    def next_clue(game_id)
      random_id = Random.new.rand(@num_clues) + 1
      clue = Clue.find_by!(id: random_id)

      if @clients.redis.set(active_clue_key(game_id), clue.id) != 'OK'
        raise StandardError, "failed to set active clue for game #{game_id}"
      end

      clue
    end

    sig { params(game_id: String).returns(Clue) }
    def active_clue(game_id)
      active_clue_id = @clients.redis.get(active_clue_key(game_id)).to_i
      Clue.find_by!(id: active_clue_id)
    end

    sig { params(clue: Clue, possible_answer: String).returns(T::Boolean) }
    def check_answer(clue, possible_answer)
      real_tokens = tokenize(clue.answer)
      possible_tokens = tokenize(possible_answer)

      real = real_tokens.join(' ')
      possible = possible_tokens.join(' ')

      value = real.jarowinkler_similar(possible)
      @clients.logger.debug "#{real} vs #{possible} [jarowinkler:#{value}]"
      return true if value >= 0.9

      # "steelers" vs "pittsburgh steelers"
      if real_tokens.length <= 2 && possible_tokens.length <= 2
        return real_tokens[-1].levenshtein_similar(possible_tokens[-1]) >= 0.8
      end

      false
    end

    private

    def tokenize(text)
      text.downcase.gsub(/[^a-z0-9\s]+/, '').split.filter { |x| STOPWORDS[x].nil? }
    end

    sig { params(game_id: String).returns(String) }
    def active_clue_key(game_id)
      "active_clue:#{game_id}"
    end
  end
end
