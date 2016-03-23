class Question < ModelBase

  @@table = 'questions'

  def self.find_by_title(title)
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM questions WHERE title = #{title}
      SQL
    return nil if result.empty?
    result.map { |result| Question.new(result) }
  end

  def self.find_by_author_id(author_id)
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM questions WHERE user_id = #{author_id}
      SQL
    return nil if result.empty?
    result.map { |result| Question.new(result) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  attr_accessor :id, :title, :body, :user_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def create
    raise 'already saved!' unless self.id.nil?
    QuestionsDatabase.instance.execute(<<-SQL, title, body, user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM users WHERE id = #{user_id}
    SQL
    result.map { |result| User.new(result) }
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end

end
