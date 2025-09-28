from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
import os

app = Flask(__name__)
CORS(app)  # Enable CORS so frontend on a different port can call backend

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

@app.route("/api/login", methods=["POST"])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"message": "Username and password required", "success": False}), 400

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        # Query the users table
        cur.execute("SELECT password FROM users WHERE username=%s", (username,))
        row = cur.fetchone()
        cur.close()
        conn.close()

        if row and row[0] == password:
            return jsonify({"message": "Login successful", "success": True}), 200
        else:
            return jsonify({"message": "Invalid credentials", "success": False}), 401

    except Exception as e:
        print(f"Error during login: {e}")
        return jsonify({"message": "Internal Server Error", "success": False}), 500

if __name__ == "__main__":
    # Listen on all interfaces inside the pod
    app.run(host="0.0.0.0", port=5000)
