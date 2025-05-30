# Step 7: CRUD Operations and Persistence
# This adds create, update, and delete functionality to our ActiveRecord implementation

require_relative 'step6_scopes'

module ActiveRecord
  class Base
    def initialize(attributes = {})
      # Track if this is a new record (not yet saved to database)
      @new_record = !attributes.key?(:id)

      # Set attributes from the hash
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    # Check if this is a new record (not yet saved)
    def new_record?
      @new_record
    end

    # Check if record is persisted (saved and not destroyed)
    def persisted?
      !new_record? && !destroyed?
    end

    # Check if record has been destroyed
    def destroyed?
      @destroyed || false
    end

    # Save the record to the database
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

    # Save with exception on failure
    def save!
      raise "Failed to save #{self.class.name}" unless save

      self
    end

    # Update attributes and save
    def update(attributes)
      attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
      save!
    end

    # Delete the record from database
    def destroy
      if persisted?
        database_table = Database.const_get("#{self.class.name.upcase}S")
        database_table.reject! { |record| record[:id] == id }
        @destroyed = true
      end
      self
    end

    private

    def create_record
      # Generate new ID
      database_table = Database.const_get("#{self.class.name.upcase}S")
      existing_ids = database_table.map { |record| record[:id] }
      new_id = existing_ids.empty? ? 1 : existing_ids.max + 1

      # Collect all attributes
      record_attributes = {}
      instance_variables.each do |var|
        next if var.to_s.start_with?('@new_record') || var.to_s.start_with?('@destroyed')

        attr_name = var.to_s.sub('@', '').to_sym
        record_attributes[attr_name] = instance_variable_get(var)
      end

      # Set ID and add to database
      record_attributes[:id] = new_id
      self.id = new_id
      database_table << record_attributes
      @new_record = false
    end

    def update_record
      # Find and update existing record
      database_table = Database.const_get("#{self.class.name.upcase}S")
      record_index = database_table.find_index { |record| record[:id] == id }

      raise "Record with id #{id} not found" unless record_index

      # Collect all attributes
      record_attributes = {}
      instance_variables.each do |var|
        next if var.to_s.start_with?('@new_record') || var.to_s.start_with?('@destroyed')

        attr_name = var.to_s.sub('@', '').to_sym
        record_attributes[attr_name] = instance_variable_get(var)
      end

      # Update the record
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
new_user = User.new(name: 'Anthony', age: 31, email: 'anthony@example.com')
puts "Is new record? #{new_user.new_record?}"
puts "Is persisted? #{new_user.persisted?}"

puts "\n=== Saving the user ==="
new_user.save!
puts "After save - Is new record? #{new_user.new_record?}"
puts "After save - Is persisted? #{new_user.persisted?}"
puts "New user: #{new_user}"
puts "Users count: #{Database::USERS.length}"

puts "\n=== Updating the user ==="
new_user.update(age: 32, email: 'anthony.updated@example.com')
puts "Updated user: #{User.find(new_user.id)}"

puts "\n=== Destroying the user ==="
new_user.destroy
puts "After destroy - Is destroyed? #{new_user.destroyed?}"
puts "Users count: #{Database::USERS.length}"
puts "Can still find user? #{User.find(new_user.id).nil?}"
