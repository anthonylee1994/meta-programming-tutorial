# 方法缺失處理 (method_missing)

class Person
  attr_accessor :name, :age

  def say_hello
    puts "Hello, my name is #{name} and I am #{age} years old"
  end

  def respond_to_missing?(method, _include_private = false)
    method.to_s.start_with?('say_')
  end

  def method_missing(method, *_args, &_block)
    if respond_to_missing?(method)
      puts method.to_s.sub('say_', '').gsub('_', ' ')
    else
      super
    end
  end
end

person = Person.new
person.name = 'Alice'
person.age = 20
person.say_hello
person.say_bye_bye
person.say_i_love_you
