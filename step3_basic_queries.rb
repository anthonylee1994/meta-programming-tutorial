# Step 3: Basic Query Methods
# This adds basic query functionality to retrieve data from our mock database

require_relative 'step2_basic_model'

class String
  def pluralize
    end_with?('y') ? "#{self[0..-2]}ies" : "#{self}s"
  end
end

module ActiveRecord
  class Base
    # Get all records from the database
    def self.all
      # Convert class name to database table constant (User -> USERS)
      table_name = name.pluralize.upcase
      data = Database.const_get(table_name)

      # Convert each hash to a model instance
      data.map { |record| new(record) }
    end

    # Get the first record
    def self.first
      all.first
    end

    # Get the last record
    def self.last
      all.last
    end

    # Find a record by ID
    def self.find(id)
      all.find { |record| record.id == id }
    end
  end
end

# Demo: Basic querying
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 3: Basic Query Methods\e[0m"
puts '------------------------------------------------------'
puts '=== All Users ==='
User.all.each { |user| puts user }

puts "\n=== First User ==="
puts User.first

puts "\n=== Last User ==="
puts User.last

puts "\n=== Find User with ID 3 ==="
puts User.find(3)
