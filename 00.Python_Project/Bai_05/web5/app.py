from pathlib import Path

from flask import Flask, redirect, render_template_string, request, url_for

app = Flask(__name__)

DATA_DIR = Path("/app/data")
DATA_FILE = DATA_DIR / "messages.txt"

HTML = """
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Docker Volume Demo</title>
</head>
<body>
    <h1>Docker Volume Demo</h1>

    <form method="post" action="/add">
        <input
            type="text"
            name="message"
            placeholder="Nhập nội dung"
            required
        >
        <button type="submit">Lưu dữ liệu</button>
    </form>

    <h2>Dữ liệu đã lưu</h2>

    {% if messages %}
        <ul>
        {% for message in messages %}
            <li>{{ message }}</li>
        {% endfor %}
        </ul>
    {% else %}
        <p>Chưa có dữ liệu.</p>
    {% endif %}
</body>
</html>
"""


def read_messages() -> list[str]:
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    if not DATA_FILE.exists():
        return []

    return DATA_FILE.read_text(encoding="utf-8").splitlines()


@app.route("/")
def home():
    return render_template_string(HTML, messages=read_messages())


@app.route("/add", methods=["POST"])
def add_message():
    message = request.form.get("message", "").strip()

    if message:
        DATA_DIR.mkdir(parents=True, exist_ok=True)

        with DATA_FILE.open("a", encoding="utf-8") as file:
            file.write(message + "\n")

    return redirect(url_for("home"))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9050)