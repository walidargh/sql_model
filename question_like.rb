class QuestionLike < ModelBase

  @@table = 'question_likes'

  def self.likers_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      users.*
    FROM
      users
    JOIN question_likes
      ON question_likes.user_id = users.id
    WHERE
      question_likes.id = #{question_id}
    SQL
    return nil if result.empty?
    result.map {|result| User.new(result)}
  end

  def self.num_likes_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      COUNT(*) as num_likes
    FROM
      question_likes
    WHERE
      question_id = #{question_id}
    SQL
    result.first["num_likes"]
  end

  def self.liked_questions_for_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      questions.*
    FROM
      questions
    JOIN question_likes
      ON question_likes.question_id = questions.id
    WHERE
      question_likes.user_id= #{user_id}
    SQL
    return nil if result.empty?
    result.map {|result| Question.new(result)}
  end

  def self.most_liked_questions(n)
    result = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      questions.*
    FROM
      questions
    JOIN question_likes
      ON question_likes.question_id = questions.id
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
        question_likes (user_id, question_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end
end
