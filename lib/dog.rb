class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: nil, breed: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql =<<-SQL
    CREATE TABLE dogs
    (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
    else
      sql =<<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(hash)
    dog = Dog.new(name: hash[:name], breed: hash[:breed])
    dog.save
    dog
  end

  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_by_id(id)
    sql =<<-SQL
    SELECT * 
    FROM dogs
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).map{|row| self.new_from_db(row)}.first
  end

  def self.find_or_create_by(name: nil, breed: nil)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    sql =<<-SQL
    SELECT * 
    FROM dogs
    WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
  end

  def update
    sql =<<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end