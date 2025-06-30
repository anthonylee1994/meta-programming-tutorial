# Step 5: Dynamic Finder Methods with method_missing

require_relative 'step4_query_class'

module ActiveRecord
  class Base
    def self.method_missing(method, *args)
      if method.to_s.start_with?('find_by_')
        attribute = method.to_s.split('find_by_').last

        value = args.first

        all.find { |record| record.send(attribute) == value }
      else
        super
      end
    end

    def self.respond_to_missing?(method, include_private = false)
      method.to_s.start_with?('find_by_') || super
    end
  end
end

# Demo: Dynamic finders
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 5: Dynamic Finder Methods with method_missing\e[0m"
puts '------------------------------------------------------'

puts '=== Find by name using find_by_name ==='
# This method doesn't exist in our code, but method_missing creates it dynamically
# Ruby parses 'find_by_name' and searches for records where name == 'Alice'
puts User.find_by_name('Alice')

puts "\n=== Find by age using find_by_age ==="
# Another dynamic method - Ruby extracts 'age' and searches for age == 28
puts User.find_by_age(28)

puts "\n=== Find by email using find_by_email ==="
# Dynamic method for email attribute
puts User.find_by_email('charlie@example.com')

puts "\n=== Check if method exists ==="
# Demonstrate that respond_to_missing? makes our dynamic methods discoverable
puts "User responds to find_by_name: #{User.respond_to?(:find_by_name)}"
puts "User responds to find_by_invalid: #{User.respond_to?(:find_by_invalid)}"
