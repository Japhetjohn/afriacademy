import pymysql

# Database configuration
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "infinity_academy"
}

# Function to establish a database connection
def get_connection():
    try:
        conn = pymysql.connect(**db_config)
        return conn
    except pymysql.MySQLError as e:
        print("Error connecting to database:", e)
        return None
