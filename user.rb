require_relative 'questions_db'

class User < ModelBase
  attr_accessor :fname, :lname
  attr_reader :id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    user = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if user.empty?

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDB.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil if user.empty?

    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def average_karma
    karma = QuestionsDB.instance.execute(<<-SQL, @id)
      SELECT
        COUNT(likes_table.user_id) / CAST(COUNT(DISTINCT(likes_table.title)) AS FLOAT) AS karma
      FROM (
        SELECT
          *
        FROM
          questions
        LEFT JOIN
          question_likes ON questions.id = question_likes.question_id
        WHERE
          questions.author_id = ?
      ) AS likes_table
    SQL
    karma
  end

  def authored_questions
    Questions.find_by_author_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def save
    if @id
      update
    else
      insert
    end
  end

  def update
    QuestionsDB.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def insert
    QuestionsDB.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDB.instance.last_insert_row_id
  end

end
