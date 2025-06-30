# Step 7: CRUD Operations and Persistence

require_relative 'step6_scopes'

module ActiveRecord
  class Base
    def initialize(attributes = {})
      @new_record = !attributes.key?(:id)

      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    def new_record?
      @new_record
    end

    def persisted?
      !new_record? && !destroyed?
    end

    def destroyed?
      @destroyed || false
    end

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

    def save!
      raise "Failed to save #{self.class.name}" unless save

      self
    end

    def update(attributes)
      attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
      save!
    end

    def destroy
      if persisted?
        database_table = Database.const_get(self.class.name.pluralize.upcase)
        database_table.reject! { |record| record[:id] == id }
        @destroyed = true
      end
      self
    end

    private

    def create_record
      database_table = Database.const_get(self.class.name.pluralize.upcase)
      existing_ids = database_table.map { |record| record[:id] }
      new_id = existing_ids.empty? ? 1 : existing_ids.max + 1

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

    def update_record
      database_table = Database.const_get(self.class.name.pluralize.upcase)
      record_index = database_table.find_index { |record| record[:id] == id }

      raise "Record with id #{id} not found" unless record_index

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
