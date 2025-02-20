from sqlalchemy.orm import Session
from app.models import User  # Replace with your actual model
import pymysql

# Function to get a user from the database using SQLAlchemy
def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

# Database configuration for pymysql
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "infinity_academy"
}

# Function to establish a database connection using pymysql
def get_connection():
    try:
        conn = pymysql.connect(**db_config)
        return conn
    except pymysql.MySQLError as e:
        print("Error connecting to database:", e)
        return None

