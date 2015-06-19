class Registration
  attr_accessor :course_id, :student_id, :id

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS registrations (
      course_id INTEGER,
      student_id INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS registrations"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    self.new.tap do |r|
      r.id = row[0]
      r.course_id =  row[1]
      r.student_id = row[2]
    end
  end


  def attribute_values
    [course_id, student_id]
  end

  def insert
    sql = <<-SQL
      INSERT INTO registrations (course_id, student_id)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, attribute_values)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM registrations")[0][0]
  end

  def update
    sql = <<-SQL
      UPDATE registrations
      SET course_id = ?, student_id = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.course_id, self.student_id)
  end

  def save
    persisted? ? update : insert
  end

  def persisted?
    self.id ? true : false
  end
	
end