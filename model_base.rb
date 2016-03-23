class ModelBase

  @@table = nil

  def self.all
    result = QuestionsDatabase.instance.execute("SELECT * FROM #{@@table}")
    result.map { |result| QuestionLike.new(result) }
  end

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM question_likes WHERE id = #{id}
      SQL
    return nil if result.empty?
    result.map { |result| QuestionLike.new(result) }
  end

  def save
    if id nil
      self.create
    else
      QuestionsDatabase.instance.execute(<<-SQL, #{self.instance_variables})
        UPDATE #{@@table}
        SET (#{self.instance_variables})
      SQL
    end
  end

end
