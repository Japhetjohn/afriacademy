# ORM Implementation
from sqlalchemy.orm import Session
from app.models import User
from app.schemas.user import UserCreate, UserUpdate


def orm_create_user(db: Session, user: UserCreate):
    new_user = User(**user.dict())
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


def orm_get_users(db: Session):
    return db.query(User).all()


def orm_update_user(db: Session, user_id: int, user: UserUpdate):
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        return None
    for key, value in user.dict(exclude_unset=True).items():
        setattr(db_user, key, value)
    db.commit()
    db.refresh(db_user)
    return db_user


def orm_delete_user(db: Session, user_id: int):
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        return None
    db.delete(db_user)
    db.commit()
    return True


# Raw SQL Implementation
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../..")))
from app.services.db_connection import get_connection


def sql_create_user(name, email, role):
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


def sql_get_users():
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


def sql_update_user(user_id, new_email):
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


def sql_delete_user(user_id):
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

