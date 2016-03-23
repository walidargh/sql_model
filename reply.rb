class Reply < ModelBase

  @@table = 'replies'

  def self.find_by_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM replies WHERE user_id = #{user_id}
      SQL
    return nil if result.empty?
    result.map { |result| Reply.new(result) }
  end

  def self.find_by_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM replies WHERE question_id = #{question_id}
      SQL
    return nil if result.empty?
    result.map { |result| Reply.new(result) }
  end

  attr_accessor :id, :body, :question_id, :user_id, :parent_id

  def initialize(options = {})
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @parent_id = options['parent_id']
  end

  def create
    raise 'already saved!' unless self.id.nil?
    QuestionsDatabase.instance.execute(<<-SQL, body, question_id, user_id, parent_id)
      INSERT INTO
        replies (body, question_id, user_id, parent_id)
      VALUES
        (?, ?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        users
      WHERE
        id = #{user_id}
    SQL

    result.map { |result| User.new(result) }
  end

  def question
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        questions
      WHERE
        id = #{question_id}
    SQL

    result.map { |result| Question.new(result) }
  end

  def parent_reply
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        replies
      WHERE
        id = #{parent_id}
    SQL

    result.map { |result| Reply.new(result) }
  end

  def child_replies
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = #{id}
    SQL

    result.map { |result| Reply.new(result) }
  end
end
