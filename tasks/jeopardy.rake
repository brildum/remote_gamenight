# frozen_string_literal: true

namespace :jeopardy do
  task :insert_clues, [:filename] do |_t, args|
    insert_clues(args)
  end

  task :fetch_clues, [:first_season, :last_season] do |_t, args|
    fetch_jeopardy_clues(args)
  end
end

def fetch_jeopardy_clues(args)
  require 'csv'
  require 'logger'
  require 'nokogiri'
  require 'faraday'
  require 'chronic'

  logger = Logger.new(STDERR)

  first = args.first_season.to_i
  last = args.last_season.to_i
  if first.zero? || last.zero?
    logger.error 'You must specify both [first_season, last_season]'
    return 1
  end

  game_ids = []
  (first..last).each do |season|
    url = "http://www.j-archive.com/showseason.php?season=#{season}"
    season_root = Nokogiri::HTML(Faraday.get(url).body)
    season_root.css('table td a').each do |a|
      game_ids << a.attr('href').split('id=')[1]
    end
  end

  logger.info "Preparing to process #{game_ids.length} games"

  csv = CSV.new(STDOUT)
  csv << ["category", "value", "clue", "answer"]

  game_ids.each do |gid|
    url = "http://www.j-archive.com/showgame.php?game_id=#{gid}"
    game_root = Nokogiri::HTML(Faraday.get(url).body)

    airdate = Chronic.parse(game_root.css('#game_title h1').text.split(' - ')[1])
    next if airdate.nil?

    logger.info "Processing #{airdate}"

    categories = []
    game_root.css('#jeopardy_round .category_name').each do |cat|
      categories << cat.text.downcase
    end

    game_root.css('#jeopardy_round .clue').each do |q|
      div = q.css('div').first
      next if div.nil?

      col_index =	q.xpath('count(preceding-sibling::*)').to_i

      clue = q.css('.clue_text').text
      category = categories[col_index]
      value = q.css('.clue_value').text[/\d+/].to_i
      if value.zero?
        value = q.css('.clue_value_daily_double').text[/\d+/].to_i
      end

      answer_re = /toggle\('[^']+'\s*,\s*'[^']+'\s*,\s*'(((\')|[^'])+)'\)/
      answer_root = Nokogiri::HTML(div.attr('onmouseover').match(answer_re).captures[0])
      answer = answer_root.css('.correct_response').text

      if clue.empty? || category.empty? || value.zero? || answer.empty?
        logger.error 'Invalid clue found'
        next
      end

      csv << [category, value, clue, answer]
    end
  end
end

def insert_clues(args)
  require 'csv'

  environment = ENV['RACK_ENV'] || 'production'

  require './app/services'
  services = Services.new(environment)

  count = 0
  CSV.foreach(File.expand_path(args.filename)) do |row|
    Trivia::Clue.new(
      category: Trivia::Category.find_or_create_by!(name: row[0].downcase),
      value: row[1].to_i,
      clue: row[2],
      answer: row[3]
    ).save!

    count += 1

    services.logger.info "#{count} clues inserted" if (count % 1000).zero?
  end
end
