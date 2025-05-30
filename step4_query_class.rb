# Step 4: Query Class for Advanced Filtering
# This introduces a separate Query class to handle complex conditions and method chaining

require_relative 'step3_basic_queries'

module ActiveRecord
  class Query
    def initialize(model_class, conditions = {})
      @model_class = model_class
      @conditions = conditions
    end

    # Add more conditions to the query (for chaining)
    def where(additional_conditions)
      Query.new(@model_class, @conditions.merge(additional_conditions))
    end

    # Execute the query and return all matching records
    def all
      # Get the raw data from database
      table_name = "#{@model_class.name.upcase}S"
      data = Database.const_get(table_name)

      # If no conditions, return all data
      return data.map { |record| @model_class.new(record) } if @conditions.empty?

      # Filter data based on conditions
      filtered_data = data.select do |record|
        @conditions.all? do |key, value|
          record_value = record[key]

          case value
          when Range
            value.include?(record_value)
          when Proc
            value.call(record_value)
          else
            record_value == value
          end
        end
      end

      # Convert to model instances
      filtered_data.map { |record| @model_class.new(record) }
    end

    # Get first matching record
    def first
      all.first
    end

    # Get last matching record
    def last
      all.last
    end
  end

  class Base
    # Create a query with conditions
    def self.where(conditions)
      Query.new(self, conditions)
    end

    # Update the existing methods to use Query class
    def self.all
      Query.new(self).all
    end

    def self.first
      Query.new(self).first
    end

    def self.last
      Query.new(self).last
    end

    # Find by conditions (returns first match)
    def self.find_by(conditions)
      Query.new(self, conditions).first
    end
  end
end

# Demo: Advanced querying
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 4: Query Class for Advanced Filtering\e[0m"
puts '------------------------------------------------------'

puts '=== Users with age 25 ==='
User.where(age: 25).all.each { |user| puts user }

puts "\n=== Users with age between 25-30 ==="
User.where(age: (25..30)).all.each { |user| puts user }

puts "\n=== Users where age > 30 ==="
User.where(age: ->(age) { age > 30 }).all.each { |user| puts user }

puts "\n=== Chaining: Users with name 'Alice' ==="
puts User.where(name: 'Alice').first

puts "\n=== Find by name ==="
puts User.find_by(name: 'Charlie')
