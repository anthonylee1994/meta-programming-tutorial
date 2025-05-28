class Person
  def initialize(name, age)
    @name = name
    @age = age
  end

  def get_name
    @name
  end

  def get_age
    @age
  end

  def set_name(name)
    @name = name
  end

  def set_age(age)
    @age = age
  end

  def say_hello
    puts "Hello, my name is #{@name} and I am #{@age} years old"
  end
end

person = Person.new('John', 20)
puts person.get_name
puts person.get_age
person.say_hello
puts '--------------------------------'
person.set_name('Jane')
person.set_age(21)
puts person.get_name
puts person.get_age
person.say_hello
