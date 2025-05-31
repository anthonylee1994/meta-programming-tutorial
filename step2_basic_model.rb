# Step 2: Basic Model Structure with Dynamic Attributes
# This shows how to create a base class with dynamic attribute generation
#
# Key metaprogramming concepts demonstrated:
# 1. Dynamic method definition using define_method
# 2. Instance variable manipulation with instance_variable_get/set
# 3. Dynamic attribute assignment in initialize
# 4. Reflection using instance_variables

require_relative 'step1_database_setup'

module ActiveRecord
  class Base
    # Constructor that accepts a hash of attributes and dynamically assigns them
    # This is the foundation of ActiveRecord's mass assignment feature
    #
    # @param attributes [Hash] Key-value pairs of attribute names and values
    def initialize(attributes = {})
      # Iterate through each attribute and dynamically call the setter method
      # This uses Ruby's 'send' method to call methods by name
      # Example: For { name: 'Alice' }, this calls send("name=", 'Alice')
      attributes.each { |key, value| send("#{key}=", value) }
    end

    # Custom string representation showing all attributes
    # This provides a readable format for debugging and inspection
    def to_s
      # Get all current attributes and format them nicely
      attrs = attributes.map { |key, value| "#{key}: #{value}" }.join(', ')
      "#<#{self.class.name} #{attrs}>"
    end

    # Extract all instance variables as a hash
    # This uses Ruby's reflection capabilities to inspect object state
    #
    # @return [Hash] All instance variables as key-value pairs
    def attributes
      hash = {}
      # instance_variables returns an array of symbols like [:@name, :@age]
      instance_variables.each do |var|
        # Remove the '@' prefix to get the clean attribute name
        name = var.to_s[1..] # Remove the '@' prefix
        # Get the actual value of the instance variable
        hash[name] = instance_variable_get(var)
      end
      hash
    end

    # Class method that dynamically defines getter and setter methods
    # This is a key metaprogramming technique - creating methods at runtime
    #
    # @param names [Array<Symbol>] List of attribute names to define
    def self.attributes(*names)
      names.each do |name|
        # define_method creates a new method on the class at runtime
        # This creates the getter method (e.g., def name)
        define_method(name) { instance_variable_get("@#{name}") }

        # This creates the setter method (e.g., def name=(value))
        # The setter stores the value in an instance variable
        define_method("#{name}=") { |value| instance_variable_set("@#{name}", value) }
      end
    end
  end
end

# Create a User model that inherits from our base ActiveRecord class
class User < ActiveRecord::Base
  # Define what attributes this model has
  # This call will dynamically create getter and setter methods for each attribute
  # Equivalent to manually writing:
  #   def id; @id; end
  #   def id=(value); @id = value; end
  #   def name; @name; end
  #   def name=(value); @name = value; end
  #   ... and so on
  attributes :id, :name, :age, :email
end

# Demo: Create and use a user instance
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 2: Basic Model Structure with Dynamic Attributes\e[0m"
puts '------------------------------------------------------'

# Create a new user using hash initialization
# The initialize method will call the dynamically created setter methods
user = User.new(id: 1, name: 'Alice', age: 30, email: 'alice@example.com')

# Display the user using our custom to_s method
puts user
# Access individual attributes using the dynamically created getter methods
puts "User name: #{user.name}"
puts "User age: #{user.age}"

# Modify attributes using the dynamically created setter methods
user.age = 31
puts "Updated user: #{user}"
