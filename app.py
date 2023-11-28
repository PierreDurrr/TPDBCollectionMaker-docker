from flask import Flask, render_template, request, redirect, url_for
import os
import requests
import subprocess
import time
import jinja2

app = Flask(__name__)

# Create Jinja2 template loader
template_loader = jinja2.Environment(loader=jinja2.FileSystemLoader("/app/templates"))

@app.route('/')
def index():
    folder_contents = os.listdir('/app/data')
    return render_template('index.html', folder_contents=folder_contents)

@app.route('/upload', methods=['POST'])
def upload():
    uploaded_file = request.files['file']
    url = request.form.get('url')
    custom_output_name = request.form.get('output_name')
    
    if uploaded_file.filename != '':
        file_path = os.path.join('/app/data', uploaded_file.filename)
        uploaded_file.save(file_path)
        return redirect(url_for('index', success=True, filename=uploaded_file.filename))
    elif url:
        # Handle URL input
        try:
            response = requests.get(url)
            html_content = response.text

            # Save HTML content to a temporary file
            temp_file_path = '/app/data/temp_html_file.html'
            with open(temp_file_path, 'w') as temp_file:
                temp_file.write(html_content)

            # Execute the command for the temporary HTML file
            execute_command(temp_file_path, custom_output_name)
            
            return redirect(url_for('index', success=True, filename=custom_output_name or 'temp_html_file.html'))
        except Exception as e:
            print(f"Error fetching HTML content from URL: {e}")
            return redirect(url_for('index', success=False))
    return redirect(url_for('index', success=False))

def execute_command(file_path, custom_output_name=None):
    # Modify the command to include the file path
    full_command = ["python3", "/app/TPDBCollectionMaker/main.py", file_path, "--always-quote"]
 
    try:
        print(f"Waiting for 10 seconds before executing command...")
        time.sleep(10)  # Add a 10-second delay

        # Execute the command without shell features
        result = subprocess.run(full_command, check=True, capture_output=True, text=True)

        # Determine the output filename
        output_filename = custom_output_name or os.path.basename(file_path)
        output_filename += "_" + time.strftime("%Y%m%d_%H%M%S") + ".yml"

        # Write the result to the output file
        output_file_path = os.path.join("/app/data", output_filename)
        with open(output_file_path, 'w') as output_file:
            output_file.write(result.stdout)

        print(f"Command executed successfully. Output written to: {output_file_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {' '.join(full_command)}")
        print(f"Error details: {e}")

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5432)
