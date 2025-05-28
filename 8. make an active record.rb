# 假設的資料庫資料
module Database
  USERS = [
    { id: 1, name: 'Alice', age: 30, email: 'alice@example.com' },
    { id: 2, name: 'Bob', age: 25, email: 'bob@example.com' },
    { id: 3, name: 'Charlie', age: 35, email: 'charlie@example.com' },
    { id: 4, name: 'David', age: 40, email: 'david@example.com' },
    { id: 5, name: 'Eve', age: 28, email: 'eve@example.com' },
    { id: 6, name: 'Frank', age: 32, email: 'frank@example.com' },
    { id: 7, name: 'Grace', age: 29, email: 'grace@example.com' },
    { id: 8, name: 'Hank', age: 31, email: 'hank@example.com' },
    { id: 9, name: 'Ivy', age: 27, email: 'ivy@example.com' },
    { id: 10, name: 'Jack', age: 33, email: 'jack@example.com' },
    { id: 11, name: 'Kate', age: 26, email: 'kate@example.com' },
    { id: 12, name: 'Liam', age: 34, email: 'liam@example.com' },
    { id: 13, name: 'Mia', age: 27, email: 'mia@example.com' },
    { id: 14, name: 'Noah', age: 30, email: 'noah@example.com' },
    { id: 15, name: 'Olivia', age: 28, email: 'olivia@example.com' },
    { id: 16, name: 'Paul', age: 31, email: 'paul@example.com' },
    { id: 17, name: 'Quinn', age: 29, email: 'quinn@example.com' },
    { id: 18, name: 'Ryan', age: 30, email: 'ryan@example.com' },
    { id: 19, name: 'Sarah', age: 25, email: 'sarah@example.com' },
    { id: 20, name: 'Tom', age: 35, email: 'tom@example.com' },
    { id: 21, name: 'Uma', age: 28, email: 'uma@example.com' },
    { id: 22, name: 'Violet', age: 32, email: 'violet@example.com' },
    { id: 23, name: 'William', age: 29, email: 'william@example.com' },
    { id: 24, name: 'Xavier', age: 31, email: 'xavier@example.com' },
    { id: 25, name: 'Yara', age: 29, email: 'yara@example.com' },
    { id: 26, name: 'Zane', age: 30, email: 'zane@example.com' }
  ]
end

# 基礎類別（模仿 Rails 的 ActiveRecord::Base）
module ActiveRecord
  class Query
    def initialize(model_class, conditions = {})
      @model_class = model_class
      @conditions = conditions
    end

    # 新增查詢條件
    def where(additional_conditions)
      Query.new(@model_class, @conditions.merge(additional_conditions))
    end

    # 取得所有資料
    def all
      data = Database.const_get("#{@model_class.name.upcase}S")
      if @conditions.empty?
        data.map { |record| @model_class.new(record) }
      else
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
    end

    # 取得第一筆資料
    def first
      all.first
    end

    # 取得最後一筆資料
    def last
      all.last
    end
  end

  class Base
    # 儲存查詢條件
    attr_accessor :conditions

    def initialize(attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    # 顯示所有屬性
    def to_s
      "#<#{self.class.name} #{attributes.map { |key, value| "#{key}: #{value}" }.join(', ')}>"
    end

    # 取得所有屬性的方法
    def attributes
      attributes = {}
      instance_variables.each do |var|
        attr_name = var.to_s.sub('@', '')
        attributes[attr_name] = instance_variable_get(var)
      end
      attributes
    end

    # 動態定義屬性存取器
    def self.attribute(name)
      define_method(name) do
        instance_variable_get("@#{name}")
      end

      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end
    end

    # 動態定義多個屬性存取器
    def self.attributes(*names)
      names.each do |name|
        attribute(name)
      end
    end

    # 返回查詢物件以支援條件查詢
    def self.where(conditions)
      Query.new(self, conditions)
    end

    def self.all
      Query.new(self).all
    end

    # 實例方法 - CRUD 操作
    def save
      true # 在這個簡化版本中，總是返回 true
    end

    # 實例方法 - 強制儲存
    def save!
      raise "Failed to save #{self.class.name}" unless save

      self
    end

    # 實例方法 - 更新資料
    def update(attributes)
      attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
      save!
    end

    # 實例方法 - 刪除資料
    def destroy
      # 在這個簡化版本中，只是標記為已刪除
      @destroyed = true
      self
    end

    # 實例方法 - 是否已刪除
    def destroyed?
      @destroyed || false
    end

    # 實例方法 - 是否已儲存
    def persisted?
      !destroyed?
    end

    # 動態定義 find_by_ 方法
    def self.method_missing(method, *args)
      if method.to_s.start_with?('find_by_')
        # 提取屬性名稱（例如 find_by_name → name）
        attribute = method.to_s.split('find_by_').last
        value = args.first

        # 在 all 中篩選符合條件的資料
        all.find { |record| record.send(attribute) == value }
      else
        super
      end
    end

    # 動態定義 respond_to_missing? 方法
    def self.respond_to_missing?(method, include_private = false)
      method.to_s.start_with?('find_by_') || super
    end

    # 動態定義 scope 方法
    def self.scope(name, body)
      # 動態定義類別方法
      define_singleton_method(name) do |*args|
        # 在類別上下文中執行 proc，返回 Query 物件
        instance_exec(*args, &body)
      end
    end
  end
end

class User < ActiveRecord::Base
  attributes :id, :name, :age, :email

  # 定義 scope - 成年人 (年齡 >= 18)
  scope :adult, -> { where(age: ->(age) { age >= 18 }) }

  # 定義 scope - 年長者 (年齡 >= 30)
  scope :senior, -> { where(age: ->(age) { age >= 30 }) }

  # 定義 scope - 年齡範圍
  scope :age_between, ->(min, max) { where(age: (min..max)) }
end

# 使用範例
user = User.new(name: 'Anthony', age: 28)
user.email = 'anthony@example.com'
puts user.name
user.save!

puts '--- User.all ---'
puts User.all

puts '--- User.where(age: 25).all ---'
puts User.where(age: 25).all

puts '--- User.find_by_name("Charlie") ---'
puts User.find_by_name('Charlie')

puts '--- User.find_by_age(28) ---'
puts User.find_by_age(28)

puts '--- User.adult (age >= 18) ---'
puts User.adult.all

puts '--- User.senior (age >= 30) ---'
puts User.senior.all

puts '--- User.age_between(25, 30) ---'
puts User.age_between(25, 30).all

puts '--- Chaining: User.adult.where(name: "Alice") ---'
puts User.adult.where(name: 'Alice').all
