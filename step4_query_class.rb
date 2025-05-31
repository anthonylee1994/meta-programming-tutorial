# Step 4: Query Class for Advanced Filtering
# This introduces a separate Query class to handle complex conditions and method chaining
#
# Key metaprogramming concepts:
# 1. Separation of concerns - queries vs models
# 2. Method chaining using return values
# 3. Polymorphic condition handling (values, ranges, procs)
# 4. Lazy evaluation patterns

require_relative 'step3_basic_queries'

module ActiveRecord
  # Query class implements the Builder pattern for constructing database queries
  # This allows for method chaining like: User.where(age: 25).where(name: 'Alice')
  class Query
    # Initialize a new query with a model class and optional conditions
    #
    # @param model_class [Class] The ActiveRecord model class (e.g., User)
    # @param conditions [Hash] Initial conditions for filtering
    def initialize(model_class, conditions = {})
      @model_class = model_class
      @conditions = conditions
    end

    # Add more conditions to the query (enables method chaining)
    # This method returns a new Query object, allowing for immutable chaining
    # Example: User.where(age: 25).where(name: 'Alice')
    #
    # @param additional_conditions [Hash] New conditions to merge
    # @return [Query] A new Query object with merged conditions
    def where(additional_conditions)
      # Create a new Query with merged conditions rather than modifying current one
      # This prevents side effects and allows for query reuse
      Query.new(@model_class, @conditions.merge(additional_conditions))
    end

    # Execute the query and return all matching records
    # This is where the actual filtering logic happens
    #
    # @return [Array<ActiveRecord::Base>] Array of matching model instances
    def all
      # Get the raw data from database using naming convention
      table_name = @model_class.name.pluralize.upcase
      data = Database.const_get(table_name)

      # If no conditions, return all data as model instances
      return data.map { |record| @model_class.new(record) } if @conditions.empty?

      # Filter data based on conditions using polymorphic condition handling
      filtered = data.filter do |record|
        # All conditions must be true (AND logic)
        @conditions.all? do |key, value|
          record_value = record[key]

          # Handle different types of condition values:
          case value
          when Range
            # Range conditions: age: (25..30) means age between 25 and 30
            value.include?(record_value)
          when Proc
            # Proc conditions: age: ->(age) { age > 30 } for custom logic
            # This allows for complex conditions that can't be expressed simply
            value.call(record_value)
          else
            # Exact match: name: 'Alice' means name equals 'Alice'
            record_value == value
          end
        end
      end

      # Convert filtered hashes to model instances
      filtered.map { |record| @model_class.new(record) }
    end

    # Get first matching record
    # Convenience method that executes the query and returns first result
    #
    # @return [ActiveRecord::Base, nil] First matching record or nil
    def first
      all.first
    end

    # Get last matching record
    # Convenience method that executes the query and returns last result
    #
    # @return [ActiveRecord::Base, nil] Last matching record or nil
    def last
      all.last
    end
  end

  class Base
    # Create a query with conditions
    # This is the entry point for building complex queries
    #
    # @param conditions [Hash] Initial filtering conditions
    # @return [Query] A new Query object for method chaining
    def self.where(conditions)
      Query.new(self, conditions)
    end

    # Update the existing methods to use Query class
    # This maintains backward compatibility while using the new Query infrastructure

    # Get all records using the Query class
    # @return [Array<ActiveRecord::Base>] All records as model instances
    def self.all
      Query.new(self).all
    end

    # Get first record using the Query class
    # @return [ActiveRecord::Base, nil] First record or nil
    def self.first
      Query.new(self).first
    end

    # Get last record using the Query class
    # @return [ActiveRecord::Base, nil] Last record or nil
    def self.last
      Query.new(self).last
    end

    # Find by conditions (returns first match)
    # Convenience method for finding a single record by multiple conditions
    #
    # @param conditions [Hash] Conditions to match
    # @return [ActiveRecord::Base, nil] First matching record or nil
    def self.find_by(conditions)
      Query.new(self, conditions).first
    end
  end
end

# Demo: Advanced querying
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 4: Query Class for Advanced Filtering\e[0m"
puts '------------------------------------------------------'

puts 'Users with age 25:'
# Demonstrate exact match filtering
User.where(age: 25).all.each { |user| puts user }

puts "\nUsers with age 25-30:"
# Demonstrate range-based filtering
User.where(age: (25..30)).all.each { |user| puts user }

puts "\nUsers where age > 30:"
# Demonstrate proc-based filtering for complex conditions
User.where(age: ->(age) { age > 30 }).all.each { |user| puts user }

puts "\nFirst user named Alice:"
# Demonstrate method chaining and first() method
puts User.where(name: 'Alice').first

puts "\nFind user named Charlie:"
# Demonstrate find_by convenience method
puts User.find_by(name: 'Charlie')
