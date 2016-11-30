require_relative 'questions_db'

class QuestionFollow
  attr_reader :id
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.find_by_id(id)
    follow = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    return nil if follow.empty?

    QuestionFollow.new(follow.first)
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON users.id = question_follows.user_id
      WHERE
        question_id = ?
    SQL

    return nil if users.empty?
    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      WHERE
        user_id = ?
    SQL

    return nil if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDB.instance.execute(<<-SQL, n)
    SELECT
    id, title, body, author_id
    FROM (
      SELECT
      *, COUNT(*) AS number_of_follows
      FROM
      questions
      JOIN
      question_follows ON questions.id = question_follows.question_id
      GROUP BY
      question_follows.question_id
      ORDER BY
      number_of_follows DESC
      LIMIT
      ?
    )
    SQL

    return nil if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
