# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

require_relative '../config'
require_relative '../services'
require_relative '../slack/messager'

module Trivia
  # GameController responds to Slack commands for a Trivia game
  class GameController
    extend T::Sig

    sig do
      params(
        config: Config::Data,
        services: Services,
        team: Slack::Team,
        game: Game,
        messager: Slack::Messager,
      )
        .void
    end
    def initialize(config:, services:, team:, game:, messager:)
      @config = T.let(config, Config::Data)
      @services = T.let(services, Services)
      @team = T.let(team, Slack::Team)
      @game = T.let(game, Game)
      @messager = T.let(messager, Slack::Messager)
    end

    sig { void }
    def activate_game
      @services.trivia.save_game(@game)

      team_help = <<~DOC
        You can create or join a team by using the *!team* command:

        `#{@config.get('botname')} !team My Team Name @user1 @user2 @user3`
      DOC

      start_help = <<~DOC
        When all the teams are ready, start the game with the *!start* command:

        `#{@config.get('botname')} !start`
      DOC

      msg = Slack::Message.new(
        blocks: [
          Slack::Message::Block.new(text: 'A new Trivia game is starting.'),
        ],
        attachments: [
          Slack::Message::Attachment.new(
            color: nil,
            text: team_help,
          ),
          Slack::Message::Attachment.new(
            color: nil,
            text: start_help,
          ),
        ],
      )
      @messager.send(:game_starting, msg)
    end

    sig do
      params(
        team: String,
        answer: String,
      )
        .void
    end
    def receive_answer(team:, answer:)
      @services.trivia.add_answer(game: @game, team: team, answer: answer)
      msg = Slack::Message.new(
        blocks: [
          Slack::Message::Block.new(text: 'Answer submitted!'),
        ],
        attachments: [
          Slack::Message::Attachment.new(
            color: nil,
            text: answer,
          ),
        ],
      )
      @messager.send(:trivia_received_answer, msg)
    end

    sig { void }
    def sync_game
      if @game.state != Game::State::STARTED
        logger.info "syncing game #{@game.id}; game not yet started, noop"
        return
      end

      since_last_clue = Time.now.to_f - @game.last_clue_sent_at
      if since_last_clue < 30
        logger.info "syncing game #{@game.id}; #{since_last_clue}s since last clue, noop"
      elsif !@game.answers_checked
        logger.info "syncing game #{@game.id}; checking answers"
        check_active_clue_answers
      elsif since_last_clue < 45
        logger.info "syncing game #{@game.id}; #{since_last_clue}s since last clue, noop"
      elsif @game.num_clues < 15
        logger.info "syncing game #{@game.id}; generating next clue"
        generate_next_clue(first: false)
      else
        end_game
      end
    end

    sig { params(first: T::Boolean).void }
    private def generate_next_clue(first:)
      clue = @services.trivia.random_clue
      @game.last_clue_sent_at = Time.now.to_f
      @game.answers_checked = false
      @game.num_clues += 1
      @game.active_clue = clue.id
      @services.trivia.save_game(@game)

      @services.trivia.clear_answers(@game)

      intro =
        if first
          'Welcome to Trivia! Your first clue:'
        else
          'Your next clue:'
        end

      text = <<~DOC
        *#{clue.clue}*

        *Category: #{clue.category.name}*

        _Answers must be submitted within 30s via DM to <@#{@team.slack_bot_id}>_
      DOC
      msg = Slack::Message.new(
        blocks: [
          Slack::Message::Block.new(text: intro),
        ],
        attachments: [
          Slack::Message::Attachment.new(
            color: nil,
            text: text,
          ),
        ],
      )
      @messager.send(:trivia_next_clue, msg)
    end

    sig { void }
    private def check_active_clue_answers
      clue = @services.trivia.get_clue(T.must(@game.active_clue))
      answers = @services.trivia.get_answers(@game)

      scores = T.let({}, T::Hash[String, Integer])
      @game.teams.each do |team|
        answer = answers[team] || ''
        score = check_answer(clue, answer) ? clue.value : 0
        scores[team] = score
        current_score = (@game.scores[team] || 0) + score
        @game.scores[team] = current_score
      end

      results = T.let([], T::Array[Slack::Message::Attachment])
      game_results.each do |game_result|
        answer_score = scores[game_result.team] || 0
        answer_text = answers[game_result.team] || 'N/A'
        result_text = <<~DOC
          *##{game_result.rank}) #{game_result.team}*: #{game_result.score} _(+#{answer_score})_
          Answer: #{answer_text}
        DOC
        results << Slack::Message::Attachment.new(
          color: answer_score > 0 ? 'good' : 'danger',
          text: result_text,
        )
      end

      @game.answers_checked = true
      @services.trivia.save_game(@game)

      text = <<~DOC
        The answer is:

        *#{clue.answer}*
      DOC
      msg = Slack::Message.new(
        blocks: [
          Slack::Message::Block.new(text: text),
        ],
        attachments: results,
      )
      @messager.send(:trivia_answer_results, msg)
    end

    sig { void }
    private def end_game
      @services.trivia.delete_game(@game)

      results = T.let([], T::Array[Slack::Message::Attachment])
      game_results.each do |game_result|
        results << Slack::Message::Attachment.new(
          color: game_result.rank == 1 ? 'good' : nil,
          text: "*##{game_result.rank}) #{game_result.team}*\nScore: #{game_result.score}",
        )
      end

      msg = Slack::Message.new(
        blocks: [
          Slack::Message::Block.new(text: 'The game has ended! Here are the results:'),
        ],
        attachments: results,
      )
      @messager.send(:trivia_game_ended_results, msg)
    end

    # GameResult provides a snapshot into the current game results
    class GameResult < T::Struct
      prop :team, String
      prop :rank, Integer
      prop :score, Integer
    end

    sig { returns(T::Array[GameResult]) }
    private def game_results
      prev_rank = 0
      prev_score = T.let(nil, T.nilable(Integer))
      @game.scores.sort_by { |_k, v| v }.reverse.map do |team, score|
        rank = (prev_score.nil? || score < prev_score) ? prev_rank + 1 : prev_rank
        prev_score = score
        prev_rank = rank
        GameResult.new(
          team: team,
          rank: rank,
          score: score,
        )
      end
    end

    sig do
      params(
        cmd: String,
        args: T::Array[String],
      )
        .void
    end
    def on_command(cmd, args)
      case cmd
      when 'start'
        on_cmd_start(args)
      when 'stop'
        on_cmd_stop(args)
      else
        @messager.send(:invalid_cmd, 'Unrecognized command')
      end
    end

    sig { params(_args: T::Array[String]).void }
    private def on_cmd_start(_args)
      teams = @services.trivia.get_teams_for_game(@game)
      if teams.empty?
        msg = <<~DOC
          You must have at least 1 team registered to play. You can register with:

          `#{@config.get('botname')} !team My Team Name @user1 @user2`
        DOC
        @messager.send(:trivia_invalid_start_teams, msg)
        return
      end

      @game.state = Game::State::STARTED
      @game.teams = teams.keys
      @game.started_at = Time.now.to_f
      generate_next_clue(first: true)
    end

    sig { params(_args: T::Array[String]).void }
    private def on_cmd_stop(_args)
      @services.trivia.delete_game(@game)
      @messager.send(:trivia_game_stopped, 'Stopped the game! Start a new game with the !play command')
    end

    sig { params(clue: Clue, possible_answer: String).returns(T::Boolean) }
    private def check_answer(clue, possible_answer)
      real_tokens = tokenize(clue.answer)
      possible_tokens = tokenize(possible_answer)

      real = real_tokens.join(' ').strip
      possible = possible_tokens.join(' ').strip

      real = clue.answer if real.blank?
      possible = possible_answer if possible.blank?

      value = real.jarowinkler_similar(possible)
      logger.debug "#{real} vs #{possible} [jarowinkler:#{value}]"
      return true if value >= 0.9

      # "steelers" vs "pittsburgh steelers"
      if real_tokens.length <= 2 && possible_tokens.length <= 2
        return real_tokens[-1].to_s.levenshtein_similar(possible_tokens[-1].to_s) >= 0.8
      end

      false
    end

    sig { params(text: String).returns(T::Array[String]) }
    private def tokenize(text)
      text.downcase.gsub(/[^a-z0-9\s]+/, '').split.filter { |x| !STOPWORDS.key?(x) }
    end

    sig { returns(Logger) }
    private def logger
      @services.clients.logger
    end
  end
end
