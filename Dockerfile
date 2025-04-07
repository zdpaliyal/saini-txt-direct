FROM python:3.9.2-slim-buster
RUN apt-get update && apt-get install -y wget \
    && apt-get install -y --no-install-recommends gcc libffi-dev musl-dev ffmpeg aria2 python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /app/
WORKDIR /app/
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir --upgrade -r requirements.txt \
    && python3 -m pip install -U yt-dlp flask

# Create a simple Flask app to serve the HTML file
RUN echo "from flask import Flask, send_from_directory\n\
app = Flask(__name__, static_folder='.')\n\
@app.route('/')\n\
def serve_html():\n\
    return send_from_directory('.', 'main.html')\n\
if __name__ == '__main__':\n\
    app.run(host='0.0.0.0', port=8000)" > /app/server.py

CMD gunicorn app:app & python3 server.py
