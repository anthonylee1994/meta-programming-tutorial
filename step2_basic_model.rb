# Step 2: Basic Model Structure with Dynamic Attributes
# This shows how to create a base class with dynamic attribute generation

require_relative 'step1_database_setup'

module ActiveRecord
  class Base
    def initialize(attributes = {})
      attributes.each { |key, value| send("#{key}=", value) }
    end

    def to_s
      attrs = attributes.map { |key, value| "#{key}: #{value}" }.join(', ')
      "#<#{self.class.name} #{attrs}>"
    end

    def attributes
      hash = {}
      instance_variables.each do |var|
        name = var.to_s[1..] # Remove the '@' prefix
        hash[name] = instance_variable_get(var)
      end
      hash
    end

    def self.attributes(*names)
      names.each do |name|
        define_method(name) { instance_variable_get("@#{name}") }
        define_method("#{name}=") { |value| instance_variable_set("@#{name}", value) }
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
