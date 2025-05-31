# Step 1: Database Setup with Mock Data
# This creates our "database" using a simple Ruby module with arrays
#
# In this tutorial, we're simulating a database using Ruby constants.
# This approach allows us to focus on the ORM metaprogramming concepts
# without getting distracted by actual database connections.

module Database
  # Mock database table for users
  # Each hash represents a database row with column names as keys
  # In a real ORM, this would be replaced by actual SQL queries
  # The structure mimics what you'd get from a real database:
  # - id: Primary key (integer)
  # - name: User's full name (string)
  # - age: User's age (integer)
  # - email: User's email address (string)
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
