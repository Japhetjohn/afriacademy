import pymysql

# Database connection settings
db_config = {
    "host": "localhost",  
    "user": "root",       
    "password": "",       
    "database": "infinity_academy"  
}

try:
    # Connect to the MySQL database
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    print("Connected to the database successfully!")

    # Test connection - fetch tables
    cursor.execute("SHOW TABLES;")
    tables = cursor.fetchall()
    print("Existing tables:", tables)

    # Close connection
    cursor.close()
    conn.close()
except pymysql.MySQLError as err:
    print("Error:", err)
