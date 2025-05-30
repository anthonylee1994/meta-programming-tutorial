# Step 6: Scopes for Reusable Query Logic
# This adds scope functionality to define reusable query methods

require_relative 'step5_dynamic_finders'

module ActiveRecord
  class Base
    # Define a scope (a reusable query method)
    def self.scope(name, body)
      # Define a singleton method (class method) with the given name
      define_singleton_method(name) do |*args|
        # Execute the block in the context of the class
        # This allows the block to call methods like 'where'
        instance_exec(*args, &body)
      end
    end
  end
end

# Update the User class to include scopes
class User < ActiveRecord::Base
  attributes :id, :name, :age, :email

  # Define scope for adults (age >= 18)
  scope :adult, -> { where(age: ->(age) { age >= 18 }) }

  # Define scope for seniors (age >= 30)
  scope :senior, -> { where(age: ->(age) { age >= 30 }) }

  # Define scope with parameters for age range
  scope :age_between, ->(min, max) { where(age: (min..max)) }

  # Define scope for young people (age < 30)
  scope :young, -> { where(age: ->(age) { age < 30 }) }
end

# Demo: Using scopes
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 6: Scopes for Reusable Query Logic\e[0m"
puts '------------------------------------------------------'

puts '=== All adult users (age >= 18) ==='
User.adult.all.each { |user| puts user }

puts "\n=== All senior users (age >= 30) ==="
User.senior.all.each { |user| puts user }

puts "\n=== Users between age 25-30 ==="
User.age_between(25, 30).all.each { |user| puts user }

puts "\n=== Young users (age < 30) ==="
User.young.all.each { |user| puts user }

puts "\n=== Chaining scopes with where ==="
User.adult.where(name: 'Alice').all.each { |user| puts user }
