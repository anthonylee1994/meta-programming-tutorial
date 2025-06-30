# Step 1: Database Setup with Mock Data

module Database
  USERS = [
    { id: 1, name: 'Alice', age: 30, email: 'alice@example.com' },
    { id: 2, name: 'Bob', age: 25, email: 'bob@example.com' },
    { id: 3, name: 'Charlie', age: 35, email: 'charlie@example.com' },
    { id: 4, name: 'David', age: 40, email: 'david@example.com' },
    { id: 5, name: 'Eve', age: 28, email: 'eve@example.com' }
  ]
end

# Demo: Access the mock data
# This section demonstrates basic access to our mock database
puts '------------------------------------------------------'
puts "\e[38;5;208mStep 1: Database Setup with Mock Data\e[0m"
puts '------------------------------------------------------'
puts "Database contains #{Database::USERS.length} users"
puts "First user: #{Database::USERS.first}"
