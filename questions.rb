class Questions
  attr_reader :id
  attr_accessor :title, :body, :author_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDB.instance.execute(<<-SQL, id)
    SELECT
    *
    FROM
    questions
    WHERE
    id = ?
    SQL
    return nil if question.empty?

    Questions.new(question.first)
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDB.instance.execute(<<-SQL, author_id)
    SELECT
    *
    FROM
    questions
    WHERE
    author_id = ?
    SQL

    return nil if questions.empty?
    questions.map { |question| Questions.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    Users.find_by_id(@author_id)
  end

  def replies
    Replies.find_by_question_id(@id)
  end


end
