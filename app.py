from flask import Flask, render_template, request, redirect, url_for
import subprocess
import requests

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/parse', methods=['POST'])
def parse_url():
    url = request.form.get('url')

    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'}

        response = requests.get(url, headers=headers)
        response.raise_for_status()

        with open('/app/data/tpdb-set.html', 'w') as file:
            file.write(response.text)

        subprocess.run(["python3", "/app/script.py"])

    except requests.RequestException as e:
        print(f"Error fetching URL: {e}")

    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5432)
