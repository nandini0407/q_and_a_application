require_relative 'questions_db'

class Reply
  attr_reader :id
  attr_accessor :body, :question_id, :parent_reply_id, :user_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    reply = QuestionsDB.instance.execute(<<-SQL, id)
    SELECT
    *
    FROM
    replies
    WHERE
    id = ?
    SQL
    return nil if reply.empty?

    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDB.instance.execute(<<-SQL, user_id)
    SELECT
    *
    FROM
    replies
    WHERE
    user_id = ?
    SQL

    return nil if replies.empty?
    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDB.instance.execute(<<-SQL, question_id)
    SELECT
    *
    FROM
    replies
    WHERE
    question_id = ?
    SQL

    return nil if replies.empty?
    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_reply_id)
  end

  def child_replies
    children = QuestionsDB.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL

    return nil if children.empty?
    children.map { |child| Reply.new(child) }
  end

  def save
    if @id
      update
    else
      insert
    end
  end

  def update
    QuestionsDB.instance.execute(<<-SQL, @body, @question_id, @parent_reply_id, @user_id, @id)
      UPDATE
        replies
      SET
        body = ?, question_id = ?, parent_reply_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

  def insert
    QuestionsDB.instance.execute(<<-SQL, @body, @question_id, @parent_reply_id, @user_id)
      INSERT INTO
        replies (body, question_id, parent_reply_id, user_id)
      VALUES
        (?, ?, ?, ?)
    SQL

    @id = QuestionsDB.instance.last_insert_row_id
  end


end
