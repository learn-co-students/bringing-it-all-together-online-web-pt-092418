class Dog
    #
    # attributes = {
    # :id => "INTEGER PRIMARY KEY",
    # :name => "TEXT",
    # :breed => "TEXT"
    # }
    #
    # ATTRIBUTES.each do |attribute_name|
    # attr_accessor attribute_name
    # end
  attr_accessor :id, :name, :breed
  # #
  # def initialize(id: nil, name:, breed:)
  #   # attributes {id => nil, name => name, breed => breed}
  #   @id = id
  #   @name = name
  #   @breed = breed
  # end

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
      self.id ||= nil
    end
  end

  def self.create_table
  # creates the dogs table in the database (FAILED - 1)
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
   # drops the dogs table from the database (FAILED - 2)
   sql = "DROP TABLE IF EXISTS dogs"
   DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.create(attributes)
  # takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database (FAILED - 5)
  # returns a new dog object (FAILED - 6)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL


      dog = DB[:conn].execute(sql, name, breed).first

      if dog
        new_dog = self.new_from_db(dog)
      else
        new_dog = self.create({:name => name, :breed => breed})
      end
      new_dog
    end

  def self.new_from_db(row)
  # creates an instance with corresponding attribute values (FAILED - 11)
    attributes_hash = {
    :id => row[0],
    :name => row[1],
    :breed => row[2]
    }
    self.new(attributes_hash)
  end

  def self.find_by_name(name)
  # returns an instance of dog that matches the name from the DB (FAILED - 12)
  sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
