from flask import Flask, request, jsonify
import psycopg2
import os

app = Flask(__name__)

# Get DB connection details from environment variables
DB_HOST = os.getenv("DB_HOST", "postgres-service")
DB_NAME = os.getenv("DB_NAME", "postgresdb")
DB_USER = os.getenv("DB_USER", "admin")
DB_PASS = os.getenv("DB_PASS", "admin123")

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS
        )
        return conn
    except Exception as e:
        print(f"Error connecting to DB: {e}")
        raise

@app.route("/")
def home():
    return "Python Backend with Postgres is running!"

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"message": "Username and password required"}), 400

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        # Query the users table
        cur.execute("SELECT password FROM users WHERE username=%s", (username,))
        row = cur.fetchone()
        cur.close()
        conn.close()

        if row and row[0] == password:
            return jsonify({"message": "Login successful"}), 200
        else:
            return jsonify({"message": "Invalid credentials"}), 401

    except Exception as e:
        print(f"Error during login: {e}")
        return jsonify({"message": "Internal Server Error"}), 500

if __name__ == "__main__":
    # Listen on all interfaces inside the pod
    app.run(host="0.0.0.0", port=5000)
