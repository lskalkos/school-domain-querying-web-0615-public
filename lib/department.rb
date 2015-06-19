class Department
  attr_accessor :id, :name

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS departments (
      id INTEGER PRIMARY KEY,
      name TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS departments"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    self.new.tap do |d|
      d.id = row[0]
      d.name = row[1]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM departments
      WHERE name = ?
      LIMIT 1;
    SQL


    row = DB[:conn].execute(sql, name).first


    self.new_from_db(row) if row

  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM departments
      WHERE id = ?
      LIMIT 1;
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def attribute_values
    [name]
  end

  def insert
    sql = <<-SQL
      INSERT INTO departments (name)
      VALUES (?)
    SQL
    DB[:conn].execute(sql, attribute_values)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM departments")[0][0]
  end

  def update
    sql = <<-SQL
      UPDATE departments
      SET name = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.id)
  end

  def save
    persisted? ? update : insert
  end

  def persisted?
    self.id ? true : false
  end

  def courses
    department_id = self.id
    test = Course.find_all_by_department_id(department_id)
  end

  def add_course(course)
    course.department_id = self.id
    course.save
    self.save
  end

  def add_student(student)

  end


end
