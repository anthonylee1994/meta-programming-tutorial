# Step 5: Dynamic Finder Methods with method_missing
# This uses Ruby's method_missing to create dynamic finder methods like find_by_name, find_by_age

require_relative 'step4_query_class'

module ActiveRecord
  class Base
    # Handle dynamic finder methods like find_by_name, find_by_age, etc.
    def self.method_missing(method, *args)
      if method.to_s.start_with?('find_by_')
        # Extract the attribute name (find_by_name -> name)
        attribute = method.to_s.split('find_by_').last
        value = args.first

        # Search all records for the matching attribute
        all.find { |record| record.send(attribute) == value }
      else
        # Call the original method_missing if it's not a find_by_ method
        super
      end
    end

    # Tell Ruby that we can respond to find_by_ methods
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
puts User.find_by_name('Alice')

puts "\n=== Find by age using find_by_age ==="
puts User.find_by_age(28)

puts "\n=== Find by email using find_by_email ==="
puts User.find_by_email('charlie@example.com')

puts "\n=== Check if method exists ==="
puts "User responds to find_by_name: #{User.respond_to?(:find_by_name)}"
puts "User responds to find_by_invalid: #{User.respond_to?(:find_by_invalid)}"
