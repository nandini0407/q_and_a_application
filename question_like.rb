require_relative 'questions_db'

class QuestionLike
  attr_reader :id
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.find_by_id(id)
    like = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil if like.empty?

    QuestionLike.new(like.first)
  end

  def self.most_liked_questions(n)
    questions = QuestionsDB.instance.execute(<<-SQL, n)
    SELECT
      id, title, body, author_id
    FROM (
      SELECT
        *, COUNT(*) AS number_of_likes
      FROM
        questions
      JOIN
        question_likes ON questions.id = question_likes.question_id
      GROUP BY
        question_likes.question_id
      ORDER BY
        number_of_likes DESC
      LIMIT
        ?
    )
    SQL

    return nil if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def self.likers_for_question_id(question_id)
    users = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_id = ?
    SQL

    return nil if users.empty?
    users.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    likers = QuestionLike.likers_for_question_id(question_id)
    return 0 if likers.nil?
    likers.length
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        user_id = ?
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
