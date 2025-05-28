module MyModule
  def self.included(base)
    base.extend(ClassMethods)
    puts "#{self} included in #{base}"
  end

  module ClassMethods
    def class_level_method
      'Class method added!'
    end
  end
end

class MyClass
  include MyModule
end

puts MyClass.class_level_method
