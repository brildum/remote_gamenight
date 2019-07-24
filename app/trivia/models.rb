# frozen_string_literal: true

# typed: strong

require 'active_record'

module Trivia
  class Clue < ActiveRecord::Base
    self.table_name = 'trivia_clues'
    belongs_to :category
  end

  class Category < ActiveRecord::Base
    self.table_name = 'trivia_categories'
    has_many :clues
  end
end
