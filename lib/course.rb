class Course
  attr_accessor :name, :id, :department_id

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS courses (
      id INTEGER PRIMARY KEY,
      name TEXT,
      department_id INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS courses"
    DB[:conn].execute(sql)
  end

  def self.find_all_by_department_id(id)
    sql = <<-SQL
      SELECT *
      FROM courses
      WHERE department_id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end

  end

  def self.new_from_db(row)
    self.new.tap do |c|
      c.id = row[0]
      c.name =  row[1]
      c.department_id = row[2]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM courses
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def attribute_values
    [name, department_id]
  end

  def insert
    sql = <<-SQL
      INSERT INTO courses
      (name, department_id)
      VALUES
      (?,?)
    SQL
    DB[:conn].execute(sql, attribute_values)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM courses")[0][0]
  end

  def update
    sql = <<-SQL
      UPDATE courses
      SET name = ?, department_id = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.department_id, self.id)
  end

  def save
    persisted? ? update : insert
  end

  def persisted?
    self.id ? true : false
  end

  def department=(department)
    self.department_id = department.id
    self.update
  end

  def department
    department_id = self.department_id
    Department.find_by_id(department_id)
  end

  def add_student(student)
    Registration.new.tap do |r|
      r.course_id = self.id
      r.student_id = student.id
    end.save
  end

  def students
    sql = <<-SQL
      SELECT *
      FROM students
      INNER JOIN registrations ON students.id = registrations.student_id
      INNER JOIN courses ON courses.id = registrations.course_id
      WHERE courses.id = ?;
    SQL

    DB[:conn].execute(sql, self.id).map do |row|
      Student.new_from_db(row)
    end

  end


end
