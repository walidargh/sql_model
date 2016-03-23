class User < ModelBase

  @@table = 'users'

  def self.find_by_name(fname, lname)
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM users WHERE fname = #{fname} AND lname = #{lname}
      SQL
    return nil if result.empty?
    result.map {|result| User.new(result)}
  end

  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise 'already saved!' unless self.id.nil?
    QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end

  def average_karma
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
         ( CAST(COUNT(question_likes.id) AS FLOAT) / COUNT(DISTINCT(questions.id))) AS karma
      FROM
        questions
      LEFT OUTER JOIN question_likes
        ON questions.id = question_likes.question_id
      WHERE
        questions.id = #{id}
    SQL
    result.first['karma']
  end

  def save

  end

end
