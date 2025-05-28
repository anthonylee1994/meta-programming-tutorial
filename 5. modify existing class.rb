# 修改已有類別（開啟類別）

class String
  def camel_case
    split('_').map(&:capitalize).join.gsub(/^./, &:downcase)
  end
end

puts 'hello_world'.camel_case
