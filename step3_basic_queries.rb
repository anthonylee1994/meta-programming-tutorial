# Step 3: Basic Query Methods
# This adds basic query functionality to retrieve data from our mock database
#
# Key concepts demonstrated:
# 1. String manipulation for table naming conventions
# 2. Class method definition for query operations
# 3. Data transformation from hash to model instances
# 4. Ruby enumerable methods for data retrieval

require_relative 'step2_basic_model'

# Add a simple pluralization method to String class
# This is a common pattern in ORMs to convert model names to table names
# Example: "User" becomes "Users", "Category" becomes "Categories"
class String
  # Simple pluralization logic for English words
  # This is a basic implementation - real ORMs use more sophisticated libraries
  #
  # @return [String] The pluralized version of the string
  def pluralize
    # Handle words ending in 'y' (like 'category' -> 'categories')
    end_with?('y') ? "#{self[0..-2]}ies" : "#{self}s"
  end
end

module ActiveRecord
  class Base
    # Get all records from the database
    # This method demonstrates the ActiveRecord pattern of converting
    # raw database data into model instances
    #
    # @return [Array<ActiveRecord::Base>] Array of model instances
    def self.all
      # Convert class name to database table constant (User -> USERS)
      # This follows Rails naming convention: Model -> table_name
      # 'User' -> 'Users' -> 'USERS' (our constant name in Database module)
      table_name = name.pluralize.upcase

      # Get the raw data array from our Database module
      # This is equivalent to: Database::USERS
      data = Database.const_get(table_name)

      # Convert each hash to a model instance
      # This transforms raw data into objects with behavior
      # Each hash becomes a User object with getter/setter methods
      data.map { |record| new(record) }
    end

    # Get the first record from the database
    # This is a convenience method that builds on the 'all' method
    #
    # @return [ActiveRecord::Base, nil] First record or nil if none exist
    def self.first
      all.first
    end

    # Get the last record from the database
    # Another convenience method for common query patterns
    #
    # @return [ActiveRecord::Base, nil] Last record or nil if none exist
    def self.last
      all.last
    end

    # Find a record by ID
    # This demonstrates basic filtering using Ruby's enumerable methods
    # In a real ORM, this would generate a SQL WHERE clause
    #
    # @param id [Integer] The ID to search for
    # @return [ActiveRecord::Base, nil] Found record or nil
    def self.find(id)
      # Use Ruby's find method to search through all records
      # This iterates through each record until it finds a match
      all.find { |record| record.id == id }
    end
  end
end

# Demo: Basic querying
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 3: Basic Query Methods\e[0m"
puts '------------------------------------------------------'

puts '=== All Users ==='
# Demonstrates fetching all records and converting them to model instances
User.all.each { |user| puts user }

puts "\n=== First User ==="
# Show the first user in the database
puts User.first

puts "\n=== Last User ==="
# Show the last user in the database
puts User.last

puts "\n=== Find User with ID 3 ==="
# Demonstrate finding a specific record by ID
puts User.find(3)
