# Complete ActiveRecord Implementation
# This combines all the steps into a single, fully functional ActiveRecord-like ORM

# Step 1: Database Setup
module Database
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
  class Query
    def initialize(model_class, conditions = {})
      @model_class = model_class
      @conditions = conditions
    end

    def where(additional_conditions)
      Query.new(@model_class, @conditions.merge(additional_conditions))
    end

    def all
      table_name = "#{@model_class.name.upcase}S"
      data = Database.const_get(table_name)

      return data.map { |record| @model_class.new(record) } if @conditions.empty?

      filtered_data = data.select do |record|
        @conditions.all? do |key, value|
          record_value = record[key]
          case value
          when Range
            value.include?(record_value)
          when Proc
            value.call(record_value)
          else
            record_value == value
          end
        end
      end

      filtered_data.map { |record| @model_class.new(record) }
    end

    def first
      all.first
    end

    def last
      all.last
    end
  end

  class Base
    def initialize(attributes = {})
      @new_record = !attributes.key?(:id)
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    def to_s
      "#<#{self.class.name} #{attributes.map { |key, value| "#{key}: #{value}" }.join(', ')}>"
    end

    def attributes
      attributes = {}
      instance_variables.each do |var|
        attr_name = var.to_s.sub('@', '')
        attributes[attr_name] = instance_variable_get(var)
      end
      attributes
    end

    # Dynamic attribute definition
    def self.attribute(name)
      define_method(name) do
        instance_variable_get("@#{name}")
      end

      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end
    end

    def self.attributes(*names)
      names.each { |name| attribute(name) }
    end

    # Query methods
    def self.where(conditions)
      Query.new(self, conditions)
    end

    def self.all
      Query.new(self).all
    end

    def self.first
      Query.new(self).first
    end

    def self.last
      Query.new(self).last
    end

    def self.find(id)
      all.find { |record| record.id == id }
    end

    def self.find_by(conditions)
      Query.new(self, conditions).first
    end

    # Dynamic finders
    def self.method_missing(method, *args)
      if method.to_s.start_with?('find_by_')
        attribute = method.to_s.split('find_by_').last
        value = args.first
        all.find { |record| record.send(attribute) == value }
      else
        super
      end
    end

    def self.respond_to_missing?(method, include_private = false)
      method.to_s.start_with?('find_by_') || super
    end

    # Scopes
    def self.scope(name, body)
      define_singleton_method(name) do |*args|
        instance_exec(*args, &body)
      end
    end

    # Persistence methods
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
        database_table = Database.const_get("#{self.class.name.upcase}S")
        database_table.reject! { |record| record[:id] == id }
        @destroyed = true
      end
      self
    end

    private

    def create_record
      database_table = Database.const_get("#{self.class.name.upcase}S")
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
      database_table = Database.const_get("#{self.class.name.upcase}S")
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

# User model with scopes
class User < ActiveRecord::Base
  attributes :id, :name, :age, :email

  scope :adult, -> { where(age: ->(age) { age >= 18 }) }
  scope :senior, -> { where(age: ->(age) { age >= 30 }) }
  scope :age_between, ->(min, max) { where(age: (min..max)) }
end

# Comprehensive demo
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 8: Complete ActiveRecord Implementation\e[0m"
puts '------------------------------------------------------'

puts '=== Complete ActiveRecord Demo ==='
puts "Users: #{User.all.count}"
puts "First user: #{User.first}"
puts "Find by name: #{User.find_by_name('Alice')}"
puts "Seniors: #{User.senior.all.count}"
puts "Age range 25-30: #{User.age_between(25, 30).all.count}"

# CRUD demo
new_user = User.new(name: 'Test User', age: 25, email: 'test@example.com')
new_user.save!
puts "Created: #{new_user}"

new_user.update(age: 26)
puts "Updated: #{User.find(new_user.id)}"

new_user.destroy
puts "Destroyed. Can find? #{!User.find(new_user.id).nil?}"
