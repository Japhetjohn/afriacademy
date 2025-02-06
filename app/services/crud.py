import sys
import os

# Add the parent directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../..")))

from app.services.db_connection import get_connection

from app.services.db_connection import get_connection

# CREATE (Insert a new user)
def create_user(name, email, role):
    conn = get_connection()
    if conn:
        try:
            cursor = conn.cursor()
            sql = "INSERT INTO users (name, email, role) VALUES (%s, %s, %s)"
            cursor.execute(sql, (name, email, role))
            conn.commit()
            print("✅ User created successfully!")
        except Exception as e:
            print(f"❌ Error creating user: {e}")
        finally:
            cursor.close()
            conn.close()

# READ (Fetch all users)
def get_users():
    conn = get_connection()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM users")
            users = cursor.fetchall()
            for user in users:
                print(user)
            return users
        except Exception as e:
            print(f"❌ Error fetching users: {e}")
        finally:
            cursor.close()
            conn.close()

# UPDATE (Modify user details)
def update_user(user_id, new_email):
    conn = get_connection()
    if conn:
        try:
            cursor = conn.cursor()
            sql = "UPDATE users SET email = %s WHERE id = %s"
            cursor.execute(sql, (new_email, user_id))
            conn.commit()
            print("✅ User updated successfully!")
        except Exception as e:
            print(f"❌ Error updating user: {e}")
        finally:
            cursor.close()
            conn.close()

# DELETE (Remove a user)
def delete_user(user_id):
    conn = get_connection()
    if conn:
        try:
            cursor = conn.cursor()
            sql = "DELETE FROM users WHERE id = %s"
            cursor.execute(sql, (user_id,))
            conn.commit()
            print("✅ User deleted successfully!")
        except Exception as e:
            print(f"❌ Error deleting user: {e}")
        finally:
            cursor.close()
            conn.close()
