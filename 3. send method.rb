# 動態派發 (send / public_send)

class Calculator
  def add(apple, boy)
    apple + boy
  end

  def multiply(apple, boy)
    apple * boy
  end
end

calc = Calculator.new
puts calc.send(:add, 3, 5)
puts calc.send(:multiply, 3, 5)
