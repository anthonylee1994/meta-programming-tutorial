# Step 6: Scopes for Reusable Query Logic

require_relative 'step5_dynamic_finders'

module ActiveRecord
  class Base
    def self.scope(name, body)
      define_singleton_method(name) do |*args|
        instance_exec(*args, &body)
      end
    end
  end
end

# Update the User class to include scopes
class User < ActiveRecord::Base
  attributes :id, :name, :age, :email

  # Define scope for adults (age >= 18)
  # This creates a class method User.adult that returns a Query object
  # The lambda creates a closure that captures the filtering logic
  scope :adult, -> { where(age: ->(age) { age >= 18 }) }

  # Define scope for seniors (age >= 30)
  # Another reusable query fragment
  scope :senior, -> { where(age: ->(age) { age >= 30 }) }

  # Define scope with parameters for age range
  # This demonstrates how scopes can accept arguments for dynamic filtering
  # The lambda parameters (min, max) become available inside the block
  scope :age_between, ->(min, max) { where(age: (min..max)) }

  # Define scope for young people (age < 30)
  # Shows different filtering logic repackaged as a named scope
  scope :young, -> { where(age: ->(age) { age < 30 }) }
end

# Demo: Using scopes
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 6: Scopes for Reusable Query Logic\e[0m"
puts '------------------------------------------------------'

puts '=== All adult users (age >= 18) ==='
# Calling the dynamically created 'adult' class method
# This executes: User.where(age: ->(age) { age >= 18 })
User.adult.all.each { |user| puts user }

puts "\n=== All senior users (age >= 30) ==="
# Another scope demonstration
User.senior.all.each { |user| puts user }

puts "\n=== Users between age 25-30 ==="
# Scope with parameters - the lambda receives min=25, max=30
User.age_between(25, 30).all.each { |user| puts user }

puts "\n=== Young users (age < 30) ==="
# Simple scope without parameters
User.young.all.each { |user| puts user }

puts "\n=== Chaining scopes with where ==="
# Demonstrates that scopes return Query objects, enabling further chaining
# This combines the 'adult' scope with an additional 'where' condition
User.adult.where(name: 'Alice').all.each { |user| puts user }
