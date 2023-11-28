#!/usr/bin/env python3

import os
import sys
import time
import subprocess
import jinja2
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Path of the folder to monitor
folder_path = os.environ.get('FOLDER_PATH', '/app/data')

# Command to execute for each new HTML file
command_to_execute = ["python3", "/app/TPDBCollectionMaker/main.py", "{input_file}", "--always-quote"]

# Create Jinja2 template loader
template_loader = jinja2.Environment(loader=jinja2.FileSystemLoader("/app/templates"))

class NewFileHandler(FileSystemEventHandler):
    def on_created(self, event):
        if event.is_directory:
            return

        file_path = event.src_path
        if file_path.endswith(".html"):
            print(f"New HTML file detected: {file_path}")
            execute_command(file_path)
            self.update_template()

    def update_template(self):
        folder_contents = os.listdir(folder_path)
        template_loader.globals.update(folder_contents=folder_contents)

def execute_command(file_path):
    # Modify the command to include the file path
    full_command = [part.format(input_file=file_path) if '{input_file}' in part else part for part in command_to_execute]

    try:
        print(f"Waiting for 10 seconds before executing command...")
        time.sleep(10)  # Add a 10-second delay

        # Execute the command without shell features
        result = subprocess.run(full_command, check=True, capture_output=True, text=True)

        # Write the result to the output file
        output_file_name = os.path.basename(file_path) + "_" + time.strftime("%Y%m%d_%H%M%S") + ".yml"
        output_file_path = os.path.join("/app/data", output_file_name)
        with open(output_file_path, 'w') as output_file:
            output_file.write(result.stdout)

        print(f"Command executed successfully. Output written to: {output_file_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {' '.join(full_command)}")
        print(f"Error details: {e}")

if __name__ == '__main__':
    print(f"Monitoring folder {folder_path} for new HTML files...")
    try:
        os.makedirs(folder_path, exist_ok=True)

        # Create the watchdog observer
        event_handler = NewFileHandler()
        observer = Observer()
        observer.schedule(event_handler, folder_path, recursive=False)
        observer.start()

        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            observer.stop()
        observer.join()

    except KeyboardInterrupt:
        print("Monitoring stopped.")
        sys.exit(0)
