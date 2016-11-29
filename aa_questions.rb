require 'sqlite3'
require 'singleton'
require 'users'
require 'questions'
require 'question_follows'
require 'question_likes'
require 'replies'

class QuestionsDB < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end
