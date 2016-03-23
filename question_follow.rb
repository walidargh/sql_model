class QuestionFollow < ModelBase

  @@table = 'question_follows'

  def self.followers_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      users.*
    FROM
      users
    JOIN question_follows
      ON question_follows.user_id = users.id
    WHERE
      question_follows.id = #{question_id}
    SQL
    return nil if result.empty?
    result.map {|result| User.new(result)}
  end

  def self.followed_questions_for_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      questions.*
    FROM
      questions
    JOIN question_follows
      ON question_follows.question_id = questions.id
    WHERE
      question_follows.user_id = #{user_id}
    SQL
    return nil if result.empty?
    result.map {|result| Question.new(result)}
  end

  def self.most_followed_questions(n)
    result = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      questions.*
    FROM
      questions
    JOIN question_follows
      ON question_follows.question_id = questions.id
    GROUP BY
      questions.id
    ORDER BY
      COUNT(*)
    LIMIT
      #{n}
    SQL
    return nil if result.empty?
    result.map { |result| Question.new(result)}
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options = {})
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise 'already saved!' unless self.id.nil?
    QuestionsDatabase.instance.execute(<<-SQL, user_id, question_id)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end
