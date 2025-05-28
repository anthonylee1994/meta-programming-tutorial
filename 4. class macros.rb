# 類別宏 (Class Macros)

class Base
  def self.add_feature(feature)
    define_method feature do
      "Feature: #{feature}"
    end
  end
end

class User < Base
  add_feature :fly
  add_feature :swim
end

user = User.new
puts user.fly
puts user.swim
