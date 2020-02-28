class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = self.new 
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    
    results = DB[:conn].execute("SELECT * FROM students ORDER BY id;")

    results.map { |row| self.new_from_db(row) }

  end

  # TODO: Refactor this class to use this helper method! More DRY. See `self.first_X_students_in_grade_10`
  def self.students_by_query(query, *params)
    results = DB[:conn].execute(query, *params)
    results.map { |row| self.new_from_db(row) }
  end

  def self.first_X_students_in_grade_10(num_students)
    query = "SELECT * FROM students WHERE grade = 10 ORDER BY id LIMIT ?;"
    self.students_by_query(query, num_students)
  end

  def self.first_student_in_grade_10
    self.first_X_students_in_grade_10(1)[0]
  end


  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM students WHERE name = ? LIMIT 1;", name).first
    self.new_from_db(row)
  end

  def self.all_students_in_grade_X(grade)
    # find the student in the database given a name
    # return a new instance of the Student class
    results = DB[:conn].execute("SELECT * FROM students WHERE grade = ?;", grade)
    results.map { |row| self.new_from_db(row) }
  end
  
  def self.all_students_in_grade_9
    self.all_students_in_grade_X(9)
  end

  def self.students_below_grade(grade)
    results = DB[:conn].execute("SELECT * FROM students WHERE grade < ?;", grade)
    results.map { |row| self.new_from_db(row) }
  end

  def self.students_below_12th_grade
    self.students_below_grade(12)
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
