# Complete ActiveRecord Implementation
# This combines all the steps into a single, fully functional ActiveRecord-like ORM
#
# This file demonstrates a complete mini-ORM that showcases advanced Ruby metaprogramming:
#
# METAPROGRAMMING TECHNIQUES USED:
# 1. Dynamic method definition (define_method, define_singleton_method)
# 2. Method missing hooks (method_missing, respond_to_missing?)
# 3. Instance variable introspection (instance_variables, instance_variable_get/set)
# 4. Class method creation (singleton methods)
# 5. Block evaluation in different contexts (instance_exec)
# 6. Dynamic constant access (const_get)
# 7. Method chaining through return values
# 8. Polymorphic condition handling
#
# ARCHITECTURAL PATTERNS DEMONSTRATED:
# - Active Record pattern (objects map to database rows)
# - Query Object pattern (separate query building from execution)
# - Builder pattern (method chaining for query construction)
# - State pattern (new, persisted, destroyed record states)

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

# Step 1: Database Setup
# Mock database using Ruby constants to simulate real database tables
module Database
  # Mock users table - in a real ORM this would be a database table
  # Each hash represents a row, keys represent column names
  USERS = [
    { id: 1, name: 'Alice', age: 30, email: 'alice@example.com' },
    { id: 2, name: 'Bob', age: 25, email: 'bob@example.com' },
    { id: 3, name: 'Charlie', age: 35, email: 'charlie@example.com' },
    { id: 4, name: 'David', age: 40, email: 'david@example.com' },
    { id: 5, name: 'Eve', age: 28, email: 'eve@example.com' }
  ]
end

# Steps 2-7: Complete ActiveRecord Implementation
module ActiveRecord
  # Query class handles complex query building and execution
  # Implements the Builder pattern for chainable queries
  class Query
    # Initialize with model class and conditions for filtering
    #
    # @param model_class [Class] The ActiveRecord model (e.g., User)
    # @param conditions [Hash] Filtering conditions
    def initialize(model_class, conditions = {})
      @model_class = model_class
      @conditions = conditions
    end

    # Add more conditions to enable method chaining
    # Returns new Query object to prevent mutation (immutable chaining)
    #
    # @param additional_conditions [Hash] New conditions to merge
    # @return [Query] New Query object with combined conditions
    def where(additional_conditions)
      Query.new(@model_class, @conditions.merge(additional_conditions))
    end

    # Execute the query and return all matching records
    # This is where the actual filtering and data transformation happens
    #
    # @return [Array<ActiveRecord::Base>] Matching model instances
    def all
      # Get raw data using naming convention (User -> USERS)
      table_name = @model_class.name.pluralize.upcase
      data = Database.const_get(table_name)

      # No filtering needed if no conditions
      return data.map { |record| @model_class.new(record) } if @conditions.empty?

      # Apply filtering with support for different condition types
      filtered_data = data.select do |record|
        @conditions.all? do |key, value|
          record_value = record[key]
          case value
          when Range
            # Range conditions: age: (25..30)
            value.include?(record_value)
          when Proc
            # Proc conditions: age: ->(age) { age > 30 }
            value.call(record_value)
          else
            # Exact match: name: 'Alice'
            record_value == value
          end
        end
      end

      # Transform filtered data into model instances
      filtered_data.map { |record| @model_class.new(record) }
    end

    # Convenience methods for common query patterns
    def first
      all.first
    end

    def last
      all.last
    end
  end

  # Base class for all ActiveRecord models
  # Provides the core ORM functionality through metaprogramming
  class Base
    # Constructor with state tracking and dynamic attribute assignment
    #
    # @param attributes [Hash] Initial attribute values
    def initialize(attributes = {})
      # Track record state for persistence operations
      @new_record = !attributes.key?(:id)

      # Dynamically assign attributes using generated setter methods
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    # String representation showing all attributes
    # Uses introspection to gather current object state
    def to_s
      "#<#{self.class.name} #{attributes.map { |key, value| "#{key}: #{value}" }.join(', ')}>"
    end

    # Extract all instance variables as a hash
    # This uses Ruby's introspection capabilities
    #
    # @return [Hash] All instance variables as key-value pairs
    def attributes
      attributes = {}
      instance_variables.each do |var|
        attr_name = var.to_s.sub('@', '')
        attributes[attr_name] = instance_variable_get(var)
      end
      attributes
    end

    # Dynamic attribute definition using metaprogramming
    # Creates getter and setter methods at runtime
    #
    # @param name [Symbol] Attribute name to define methods for
    def self.attribute(name)
      # Create getter method: def name; @name; end
      define_method(name) do
        instance_variable_get("@#{name}")
      end

      # Create setter method: def name=(value); @name = value; end
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end
    end

    # Convenience method for defining multiple attributes at once
    #
    # @param names [Array<Symbol>] List of attribute names
    def self.attributes(*names)
      names.each { |name| attribute(name) }
    end

    # Query interface - returns Query objects for method chaining

    # Create a query with filtering conditions
    #
    # @param conditions [Hash] Filtering conditions
    # @return [Query] Query object for method chaining
    def self.where(conditions)
      Query.new(self, conditions)
    end

    # Get all records as model instances
    def self.all
      Query.new(self).all
    end

    # Get first record
    def self.first
      Query.new(self).first
    end

    # Get last record
    def self.last
      Query.new(self).last
    end

    # Find record by ID
    #
    # @param id [Integer] Record ID to find
    # @return [ActiveRecord::Base, nil] Found record or nil
    def self.find(id)
      all.find { |record| record.id == id }
    end

    # Find first record matching conditions
    #
    # @param conditions [Hash] Conditions to match
    # @return [ActiveRecord::Base, nil] First matching record or nil
    def self.find_by(conditions)
      Query.new(self, conditions).first
    end

    # Dynamic finders using method_missing metaprogramming
    # Handles methods like find_by_name, find_by_age, etc.
    #
    # @param method [Symbol] Method name that was called
    # @param args [Array] Arguments passed to the method
    def self.method_missing(method, *args)
      if method.to_s.start_with?('find_by_')
        # Extract attribute name from method name
        attribute = method.to_s.split('find_by_').last
        value = args.first
        # Find record where attribute equals value
        all.find { |record| record.send(attribute) == value }
      else
        # Delegate to normal method_missing behavior
        super
      end
    end

    # Enable introspection of dynamic finder methods
    #
    # @param method [Symbol] Method name being checked
    # @param include_private [Boolean] Include private methods
    # @return [Boolean] True if we can handle this method
    def self.respond_to_missing?(method, include_private = false)
      method.to_s.start_with?('find_by_') || super
    end

    # Scopes - reusable query fragments using metaprogramming
    # Creates named class methods that return Query objects
    #
    # @param name [Symbol] Name of the scope method
    # @param body [Proc] Block containing query logic
    def self.scope(name, body)
      # Create a singleton method (class method) with the given name
      define_singleton_method(name) do |*args|
        # Execute the block in the context of the class
        # This allows the block to call methods like 'where'
        instance_exec(*args, &body)
      end
    end

    # Persistence methods for CRUD operations

    # Record state inquiry methods
    def new_record?
      @new_record
    end

    def persisted?
      !new_record? && !destroyed?
    end

    def destroyed?
      @destroyed || false
    end

    # Save record to database (create or update based on state)
    #
    # @return [Boolean] True if save succeeded
    def save
      if @new_record
        create_record
      else
        update_record
      end
      true
    rescue StandardError => e
      puts "Error saving record: #{e.message}"
      false
    end

    # Save with exception on failure (bang method pattern)
    #
    # @return [ActiveRecord::Base] Self for method chaining
    # @raise [RuntimeError] If save fails
    def save!
      raise "Failed to save #{self.class.name}" unless save

      self
    end

    # Update attributes and save
    #
    # @param attributes [Hash] Attributes to update
    # @return [ActiveRecord::Base] Self for method chaining
    def update(attributes)
      attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
      save!
    end

    # Remove record from database
    #
    # @return [ActiveRecord::Base] Self (even though destroyed)
    def destroy
      if persisted?
        database_table = Database.const_get(self.class.name.pluralize.upcase)
        database_table.reject! { |record| record[:id] == id }
        @destroyed = true
      end
      self
    end

    private

    # Create new record in database
    # Generates ID and adds record to database table
    def create_record
      database_table = Database.const_get(self.class.name.pluralize.upcase)
      existing_ids = database_table.map { |record| record[:id] }
      new_id = existing_ids.empty? ? 1 : existing_ids.max + 1

      # Collect all attributes from instance variables
      record_attributes = {}
      instance_variables.each do |var|
        next if var.to_s.start_with?('@new_record') || var.to_s.start_with?('@destroyed')

        attr_name = var.to_s.sub('@', '').to_sym
        record_attributes[attr_name] = instance_variable_get(var)
      end

      record_attributes[:id] = new_id
      self.id = new_id
      database_table << record_attributes
      @new_record = false
    end

    # Update existing record in database
    # Finds record by ID and replaces with current attributes
    def update_record
      database_table = Database.const_get(self.class.name.pluralize.upcase)
      record_index = database_table.find_index { |record| record[:id] == id }
      raise "Record with id #{id} not found" unless record_index

      # Collect current attributes
      record_attributes = {}
      instance_variables.each do |var|
        next if var.to_s.start_with?('@new_record') || var.to_s.start_with?('@destroyed')

        attr_name = var.to_s.sub('@', '').to_sym
        record_attributes[attr_name] = instance_variable_get(var)
      end

      database_table[record_index] = record_attributes
    end
  end
end

# User model with scopes demonstrating the complete ORM functionality
class User < ActiveRecord::Base
  # Define model attributes using metaprogramming
  attributes :id, :name, :age, :email

  # Define scopes using dynamic method creation
  scope :adult, -> { where(age: ->(age) { age >= 18 }) }
  scope :senior, -> { where(age: ->(age) { age >= 30 }) }
  scope :age_between, ->(min, max) { where(age: (min..max)) }
end

# Comprehensive demo showing all ORM features
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 8: Complete ActiveRecord Implementation\e[0m"
puts '------------------------------------------------------'

puts '=== Complete ActiveRecord Demo ==='
puts "Users: #{User.all.count}"                                    # Query all records
puts "First user: #{User.first}"                                   # Get first record
puts "Find by name: #{User.find_by_name('Alice')}"                 # Dynamic finder
puts "Seniors: #{User.senior.all.count}"                           # Scope usage
puts "Age range 25-30: #{User.age_between(25, 30).all.count}"      # Parameterized scope

# CRUD demo showing persistence operations
new_user = User.new(name: 'Test User', age: 25, email: 'test@example.com')
new_user.save! # Create operation
puts "Created: #{new_user}"

new_user.update(age: 26)                                           # Update operation
puts "Updated: #{User.find(new_user.id)}"

new_user.destroy                                                   # Delete operation
puts "Destroyed. Can find? #{!User.find(new_user.id).nil?}"
