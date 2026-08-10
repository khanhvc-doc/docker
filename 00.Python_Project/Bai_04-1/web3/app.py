from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "<h1>Hello from Web3 - Docker compose Bai 4.1 them web 3</h1>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9113)