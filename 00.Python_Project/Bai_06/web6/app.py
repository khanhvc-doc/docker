import os

from flask import Flask

from database import db


app = Flask(__name__)

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg://employee_user:employee_pass@postgres:5432/employee_db",
)

app.config["SQLALCHEMY_DATABASE_URI"] = DATABASE_URL

app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db.init_app(app)


@app.route("/")
def home():

    return """
    <h1>Employee Manager</h1>

    <p>Flask running successfully.</p>

    <p>Database configuration loaded.</p>
    """


if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=9061
    )