# Step 3: Basic Query Methods

require_relative 'step2_basic_model'

class String
  def pluralize
    end_with?('y') ? "#{self[0..-2]}ies" : "#{self}s"
  end
end

module ActiveRecord
  class Base
    def self.all
      table_name = name.pluralize.upcase

      data = Database.const_get(table_name)

      data.map { |record| new(record) }
    end

    def self.first
      all.first
    end

    def self.last
      all.last
    end

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
