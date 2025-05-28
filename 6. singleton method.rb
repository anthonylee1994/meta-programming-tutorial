str = 'hello_world'

def str.camel_case
  split('_').map(&:capitalize).join.gsub(/^./, &:downcase)
end

puts str.camel_case
