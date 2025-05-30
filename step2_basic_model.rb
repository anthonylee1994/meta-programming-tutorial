# Step 2: Basic Model Structure with Dynamic Attributes
# This shows how to create a base class with dynamic attribute generation

require_relative 'step1_database_setup'

module ActiveRecord
  class Base
    def initialize(attributes = {})
      # Set attributes from the hash
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    # Display all attributes nicely
    def to_s
      "#<#{self.class.name} #{attributes.map { |key, value| "#{key}: #{value}" }.join(', ')}>"
    end

    # Get all attributes as a hash
    def attributes
      attributes = {}
      instance_variables.each do |var|
        attr_name = var.to_s.sub('@', '')
        attributes[attr_name] = instance_variable_get(var)
      end
      attributes
    end

    # Dynamically define a single attribute with getter and setter
    def self.attribute(name)
      define_method(name) do
        instance_variable_get("@#{name}")
      end

      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end
    end

    # Dynamically define multiple attributes at once
    def self.attributes(*names)
      names.each do |name|
        attribute(name)
      end
    end
  end
end

# Create a User model
class User < ActiveRecord::Base
  # Define what attributes this model has
  attributes :id, :name, :age, :email
end

# Demo: Create and use a user instance
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 2: Basic Model Structure with Dynamic Attributes\e[0m"
puts '------------------------------------------------------'

user = User.new(id: 1, name: 'Alice', age: 30, email: 'alice@example.com')

puts user
puts "User name: #{user.name}"
puts "User age: #{user.age}"

# Modify attributes
user.age = 31
puts "Updated user: #{user}"
