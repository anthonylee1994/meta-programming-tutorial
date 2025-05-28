# 動態定義方法

class Person
  %w[name age].each do |attr|
    define_method "get_#{attr}" do
      instance_variable_get("@#{attr}")
    end

    define_method "set_#{attr}" do |value|
      instance_variable_set("@#{attr}", value)
    end
  end

  def say_hello
    puts "Hello, my name is #{get_name} and I am #{get_age} years old"
  end
end

person = Person.new
person.set_name('Alice')
person.set_age(20)
person.say_hello
