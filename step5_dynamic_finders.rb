# Step 5: Dynamic Finder Methods with method_missing
# This uses Ruby's method_missing to create dynamic finder methods like find_by_name, find_by_age
#
# Key metaprogramming concepts:
# 1. method_missing hook - Ruby's mechanism for handling undefined methods
# 2. String parsing to extract meaningful information from method names
# 3. respond_to_missing? for proper method introspection
# 4. Dynamic method delegation based on naming conventions

require_relative 'step4_query_class'

module ActiveRecord
  class Base
    # Handle dynamic finder methods like find_by_name, find_by_age, etc.
    # This is Ruby's "method_missing" hook - called when a method doesn't exist
    #
    # Ruby's method lookup process:
    # 1. Look for the method in the object's class
    # 2. Look in included modules
    # 3. Look in parent classes
    # 4. Call method_missing as a last resort
    #
    # @param method [Symbol] The method name that was called
    # @param args [Array] Arguments passed to the method
    def self.method_missing(method, *args)
      # Check if the method name follows our dynamic finder pattern
      if method.to_s.start_with?('find_by_')
        # Extract the attribute name from the method name
        # Example: 'find_by_name' -> 'name', 'find_by_email' -> 'email'
        attribute = method.to_s.split('find_by_').last

        # Get the value to search for (first argument)
        value = args.first

        # Search all records for the matching attribute using our existing infrastructure
        # This leverages the 'all' method and Ruby's enumerable find method
        # It's equivalent to: User.all.find { |user| user.name == 'Alice' }
        all.find { |record| record.send(attribute) == value }
      else
        # If it's not a find_by_ method, delegate to Ruby's default behavior
        # This maintains normal Ruby error handling for truly missing methods
        super
      end
    end

    # Tell Ruby that we can respond to find_by_ methods
    # This hook works with method_missing to make our dynamic methods
    # appear as "real" methods to Ruby's introspection system
    #
    # Without this, code like User.respond_to?(:find_by_name) would return false
    # even though we can handle the method via method_missing
    #
    # @param method [Symbol] The method name being checked
    # @param include_private [Boolean] Whether to include private methods
    # @return [Boolean] True if we can handle this method
    def self.respond_to_missing?(method, include_private = false)
      # Return true for any find_by_ method, false otherwise (delegate to super)
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
