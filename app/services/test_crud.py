from crud import create_user, get_users, update_user, delete_user

# Create a new user
create_user("Japhet", "japhet@example.com", "student")

# Get all users
print("\n🔹 Fetching all users:")
get_users()

# Update a user's email
update_user(1, "newemail@example.com")

# Delete a user
delete_user(1)
