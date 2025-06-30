# Step 4: Query Class for Advanced Filtering

require_relative 'step3_basic_queries'

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
      table_name = @model_class.name.pluralize.upcase
      data = Database.const_get(table_name)

      return data.map { |record| @model_class.new(record) } if @conditions.empty?

      filtered = data.filter do |record|
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

      filtered.map { |record| @model_class.new(record) }
    end

    def first
      all.first
    end

    def last
      all.last
    end
  end

  class Base
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

    def self.find_by(conditions)
      Query.new(self, conditions).first
    end
  end
end

# Demo: Advanced querying
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 4: Query Class for Advanced Filtering\e[0m"
puts '------------------------------------------------------'

puts 'Users with age 25:'
# Demonstrate exact match filtering
User.where(age: 25).all.each { |user| puts user }

puts "\nUsers with age 25-30:"
# Demonstrate range-based filtering
User.where(age: (25..30)).all.each { |user| puts user }

puts "\nUsers where age > 30:"
# Demonstrate proc-based filtering for complex conditions
User.where(age: ->(age) { age > 30 }).all.each { |user| puts user }

puts "\nFirst user named Alice:"
# Demonstrate method chaining and first() method
puts User.where(name: 'Alice').first

puts "\nFind user named Charlie:"
# Demonstrate find_by convenience method
puts User.find_by(name: 'Charlie')
