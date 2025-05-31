# Step 7: CRUD Operations and Persistence
# This adds create, update, and delete functionality to our ActiveRecord implementation
#
# Key concepts demonstrated:
# 1. Record state tracking (new, persisted, destroyed)
# 2. CRUD operations (Create, Read, Update, Delete)
# 3. Database simulation with array manipulation
# 4. Error handling and validation patterns
# 5. Instance variable introspection for attribute collection

require_relative 'step6_scopes'

module ActiveRecord
  class Base
    # Enhanced constructor that tracks record state
    # This version adds persistence state tracking to determine if a record
    # is new (needs to be created) or existing (needs to be updated)
    #
    # @param attributes [Hash] Initial attribute values
    def initialize(attributes = {})
      # Track if this is a new record (not yet saved to database)
      # Records are considered new if they don't have an ID
      # This mimics how real ORMs determine record state
      @new_record = !attributes.key?(:id)

      # Set attributes from the hash using our dynamic setter methods
      # This reuses the metaprogramming infrastructure from earlier steps
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    # Check if this is a new record (not yet saved)
    # New records need to be inserted into the database
    #
    # @return [Boolean] True if record hasn't been saved yet
    def new_record?
      @new_record
    end

    # Check if record is persisted (saved and not destroyed)
    # Persisted records exist in the database and can be updated
    #
    # @return [Boolean] True if record exists in database and isn't destroyed
    def persisted?
      !new_record? && !destroyed?
    end

    # Check if record has been destroyed
    # Destroyed records have been removed from the database
    #
    # @return [Boolean] True if record has been deleted
    def destroyed?
      @destroyed || false
    end

    # Save the record to the database
    # This method handles both create and update operations based on record state
    # It demonstrates the "save" pattern common in ORMs
    #
    # @return [Boolean] True if save succeeded, false if it failed
    def save
      if @new_record
        # New records need to be created (inserted into database)
        create_record
      else
        # Existing records need to be updated
        update_record
      end
      true # Indicate success
    rescue StandardError => e
      # Handle any errors that occur during save operation
      puts "Error saving record: #{e.message}"
      false # Indicate failure
    end

    # Save with exception on failure
    # This is the "bang" version that raises an exception instead of returning false
    # Common pattern in Ruby libraries (save vs save!)
    #
    # @return [ActiveRecord::Base] Returns self for method chaining
    # @raise [RuntimeError] If save operation fails
    def save!
      raise "Failed to save #{self.class.name}" unless save

      self # Return self for method chaining
    end

    # Update attributes and save
    # Convenience method that combines attribute assignment with persistence
    # This implements the common "update" pattern in ORMs
    #
    # @param attributes [Hash] Attributes to update
    # @return [ActiveRecord::Base] Returns self for method chaining
    def update(attributes)
      # Update each attribute using the setter methods (if they exist)
      attributes.each do |key, value|
        # Only set attributes that have setter methods defined
        send("#{key}=", value) if respond_to?("#{key}=")
      end
      save! # Save the changes and return self
    end

    # Delete the record from database
    # This implements the "destroy" pattern that removes records
    # Only persisted records can be destroyed
    #
    # @return [ActiveRecord::Base] Returns self (even though record is destroyed)
    def destroy
      if persisted?
        # Get the database table for this model class
        database_table = Database.const_get(self.class.name.pluralize.upcase)

        # Remove the record from our mock database
        # reject! modifies the array in place, removing matching elements
        database_table.reject! { |record| record[:id] == id }

        # Mark this object as destroyed
        @destroyed = true
      end
      self # Return self to match ActiveRecord behavior
    end

    private

    # Create a new record in the database
    # This handles the "insert" operation for new records
    # It demonstrates ID generation and attribute collection
    def create_record
      # Generate new ID by finding the highest existing ID and adding 1
      # In a real database, this would be handled by auto-increment
      database_table = Database.const_get(self.class.name.pluralize.upcase)
      existing_ids = database_table.map { |record| record[:id] }
      new_id = existing_ids.empty? ? 1 : existing_ids.max + 1

      # Collect all attributes from instance variables
      # This uses Ruby's introspection to gather all object state
      record_attributes = {}
      instance_variables.each do |var|
        # Skip internal state variables (new_record, destroyed flags)
        next if var.to_s.start_with?('@new_record') || var.to_s.start_with?('@destroyed')

        # Convert instance variable name to attribute name
        # @name becomes :name, @age becomes :age, etc.
        attr_name = var.to_s.sub('@', '').to_sym
        record_attributes[attr_name] = instance_variable_get(var)
      end

      # Set the generated ID on both the hash and the object
      record_attributes[:id] = new_id
      self.id = new_id

      # Add the new record to our mock database
      database_table << record_attributes

      # Mark as no longer a new record
      @new_record = false
    end

    # Update an existing record in the database
    # This handles the "update" operation for persisted records
    def update_record
      # Find and update existing record in our mock database
      database_table = Database.const_get(self.class.name.pluralize.upcase)
      record_index = database_table.find_index { |record| record[:id] == id }

      # Ensure the record exists before trying to update it
      raise "Record with id #{id} not found" unless record_index

      # Collect all current attributes (same logic as create_record)
      record_attributes = {}
      instance_variables.each do |var|
        # Skip internal state variables
        next if var.to_s.start_with?('@new_record') || var.to_s.start_with?('@destroyed')

        attr_name = var.to_s.sub('@', '').to_sym
        record_attributes[attr_name] = instance_variable_get(var)
      end

      # Replace the existing record with the updated attributes
      database_table[record_index] = record_attributes
    end
  end
end

# Demo: CRUD operations
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 7: CRUD Operations and Persistence\e[0m"
puts '------------------------------------------------------'

puts '=== Original database size ==='
puts "Users count: #{Database::USERS.length}"

puts "\n=== Creating a new user ==="
# Create a new user object (in memory, not saved yet)
new_user = User.new(name: 'Anthony', age: 31, email: 'anthony@example.com')
puts "Is new record? #{new_user.new_record?}" # Should be true
puts "Is persisted? #{new_user.persisted?}" # Should be false

puts "\n=== Saving the user ==="
# Persist the user to the database
new_user.save!
puts "After save - Is new record? #{new_user.new_record?}" # Should be false
puts "After save - Is persisted? #{new_user.persisted?}"   # Should be true
puts "New user: #{new_user}"
puts "Users count: #{Database::USERS.length}"              # Should be increased

puts "\n=== Updating the user ==="
# Modify existing user attributes and save changes
new_user.update(age: 32, email: 'anthony.updated@example.com')
puts "Updated user: #{User.find(new_user.id)}" # Show updated values

puts "\n=== Destroying the user ==="
# Remove the user from the database
new_user.destroy
puts "After destroy - Is destroyed? #{new_user.destroyed?}" # Should be true
puts "Users count: #{Database::USERS.length}"               # Should be back to original
puts "Can still find user? #{User.find(new_user.id).nil?}" # Should be true (can't find)
